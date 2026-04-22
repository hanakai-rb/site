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
 */

import { readFile, writeFile, mkdir } from "node:fs/promises";
import { existsSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import satori from "satori";
import { Resvg } from "@resvg/resvg-js";

import { loadFonts } from "./fonts.mjs";
import { templates } from "./templates.mjs";

const projectRoot = resolve(fileURLToPath(import.meta.url), "../../..");
const outputRoot = join(projectRoot, "public", "og");

const WIDTH = 1200;
const HEIGHT = 630;

async function main() {
  const manifestPath = process.argv[2];
  if (!manifestPath) {
    console.error("Usage: render.mjs <manifest.json>");
    process.exit(1);
  }

  const manifest = JSON.parse(await readFile(manifestPath, "utf8"));
  const fonts = await loadFonts();

  if (!existsSync(outputRoot)) {
    await mkdir(outputRoot, { recursive: true });
  }

  let count = 0;
  const start = Date.now();
  for (const entry of manifest) {
    const template = templates[entry.template];
    if (!template) {
      throw new Error(`Unknown template: ${entry.template}`);
    }

    const tree = template(entry.data);
    const svg = await satori(tree, { width: WIDTH, height: HEIGHT, fonts });
    const png = new Resvg(svg, { fitTo: { mode: "width", value: WIDTH } }).render().asPng();

    const outPath = join(outputRoot, entry.output);
    await mkdir(dirname(outPath), { recursive: true });
    await writeFile(outPath, png);
    count += 1;
  }

  const elapsed = ((Date.now() - start) / 1000).toFixed(2);
  console.log(`✓ Rendered ${count} og:image(s) in ${elapsed}s → public/og/`);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
