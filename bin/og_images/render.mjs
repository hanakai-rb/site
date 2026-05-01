#!/usr/bin/env node
/**
 * Render og:images from a manifest produced by Ruby.
 *
 * Usage: node bin/og_images/render.mjs <manifest.json>
 *
 * The manifest is an array of entries:
 *   { output: "blog/foo.png", template: "post", data: { title, ... } }
 *
 * Output PNGs are written under public/og/ (relative to project root).
 *
 * Renders are cached at tmp/og_images/cache/<sha256>.png, content-addressed
 * by the entry's {template, data}. Two manifest entries with the same inputs
 * but different output paths share a single render. The cache is invalidated
 * wholesale when the renderer fingerprint (this script, templates, fonts,
 * deps) changes — see computeRendererFingerprint below.
 */

import { readFile, writeFile, mkdir, rm, copyFile, readdir } from "node:fs/promises";
import { existsSync } from "node:fs";
import { createHash } from "node:crypto";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import satori from "satori";
import { Resvg } from "@resvg/resvg-js";

import { loadFonts } from "./fonts.mjs";
import { templates } from "./templates.mjs";

const projectRoot = resolve(fileURLToPath(import.meta.url), "../../..");
const outputRoot = join(projectRoot, "public", "og");
const cacheRoot = join(projectRoot, "tmp", "og_images", "cache");
const fingerprintPath = join(cacheRoot, ".fingerprint");

const WIDTH = 1024;
const HEIGHT = 630;

// Bump to force a fresh render on next run. This works because render.mjs is
// itself one of the files hashed into the renderer fingerprint, so any edit
// will invalidate the cache.
const CACHE_VERSION = "1";

// Lazy so a fully warm cache skips wawoff2 decompression entirely.
let fontsPromise = null;
function getFonts() {
  return (fontsPromise ??= loadFonts());
}

async function listFontFiles() {
  const fontsDir = join(projectRoot, "app", "assets", "fonts");
  const out = [];
  async function walk(dir) {
    const entries = await readdir(dir, { withFileTypes: true });
    for (const entry of entries) {
      const full = join(dir, entry.name);
      if (entry.isDirectory()) await walk(full);
      else if (entry.isFile() && entry.name.endsWith(".woff2")) out.push(full);
    }
  }
  await walk(fontsDir);
  return out;
}

// Hash of every input that affects how an entry renders, independent of the
// entry itself. A change here wipes the whole cache.
//
// Hashes project-relative paths (not absolute) so the fingerprint is stable
// across machines — local dev and CI must agree.
async function computeRendererFingerprint() {
  const absolutePaths = [
    fileURLToPath(import.meta.url),
    join(projectRoot, "bin", "og_images", "templates.mjs"),
    join(projectRoot, "bin", "og_images", "fonts.mjs"),
    join(projectRoot, "package-lock.json"),
    ...(await listFontFiles()),
  ];

  const entries = absolutePaths
    .map((abs) => ({ rel: relative(projectRoot, abs), abs }))
    .sort((a, b) => a.rel.localeCompare(b.rel));

  const hash = createHash("sha256");
  for (const { rel, abs } of entries) {
    // Null byte separator prevents (path, content) pairs from concatenating
    // ambiguously — e.g., ("a", "bc") colliding with ("ab", "c").
    hash.update(rel);
    hash.update("\0");
    hash.update(await readFile(abs));
    hash.update("\0");
  }
  return hash.digest("hex");
}

// Recursively sort object keys so that the JSON we hash is order-independent.
// Defends against future reordering of fields in the Ruby manifest builder.
function sortKeys(value) {
  if (Array.isArray(value)) return value.map(sortKeys);
  if (value !== null && typeof value === "object") {
    return Object.keys(value)
      .sort()
      .reduce((acc, key) => {
        acc[key] = sortKeys(value[key]);
        return acc;
      }, {});
  }
  return value;
}

function entryKey(entry) {
  const canonical = JSON.stringify({
    template: entry.template,
    data: sortKeys(entry.data),
  });
  return createHash("sha256").update(canonical).digest("hex");
}

async function readFingerprint() {
  try {
    return (await readFile(fingerprintPath, "utf8")).trim();
  } catch {
    return null;
  }
}

// If the renderer fingerprint differs from the one stored alongside the
// cache, wipe the cache directory and write the new fingerprint. Safe to
// call when the cache directory does not yet exist.
async function ensureCacheReady(currentFingerprint) {
  if ((await readFingerprint()) === currentFingerprint) return;

  await rm(cacheRoot, { recursive: true, force: true });
  await mkdir(cacheRoot, { recursive: true });
  await writeFile(fingerprintPath, currentFingerprint);
}

async function renderEntry(entry) {
  const template = templates[entry.template];
  if (!template) throw new Error(`Unknown template: ${entry.template}`);

  const tree = template(entry.data);
  const fonts = await getFonts();
  const svg = await satori(tree, { width: WIDTH, height: HEIGHT, fonts });
  return new Resvg(svg, { fitTo: { mode: "width", value: WIDTH } }).render().asPng();
}

async function main() {
  const manifestPath = process.argv[2];
  if (!manifestPath) {
    console.error("Usage: render.mjs <manifest.json>");
    process.exit(1);
  }

  const manifest = JSON.parse(await readFile(manifestPath, "utf8"));

  await ensureCacheReady(await computeRendererFingerprint());
  await mkdir(outputRoot, { recursive: true });

  let hits = 0;
  let misses = 0;
  const start = Date.now();

  for (const entry of manifest) {
    const cachePath = join(cacheRoot, `${entryKey(entry)}.png`);
    const outPath = join(outputRoot, entry.output);
    await mkdir(dirname(outPath), { recursive: true });

    if (existsSync(cachePath)) {
      await copyFile(cachePath, outPath);
      hits += 1;
    } else {
      const png = await renderEntry(entry);
      await writeFile(cachePath, png);
      await writeFile(outPath, png);
      misses += 1;
    }
  }

  const elapsed = ((Date.now() - start) / 1000).toFixed(2);
  console.log(`✓ og:images: ${hits} cached, ${misses} rendered in ${elapsed}s → public/og/`);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
