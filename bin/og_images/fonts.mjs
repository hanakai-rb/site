/**
 * Load site fonts for Satori. The site ships .woff2 only; Satori needs raw
 * sfnt-flavoured TTF/OTF data, so we decompress on the fly with wawoff2.
 */

import { readFile } from "node:fs/promises";
import { resolve } from "node:path";
import { fileURLToPath } from "node:url";
import wawoff2 from "wawoff2";

const projectRoot = resolve(fileURLToPath(import.meta.url), "../../..");

const fontFiles = [
  {
    name: "Faire Sprig Sans",
    weight: 400,
    style: "normal",
    path: "app/assets/fonts/faire-sprig-sans/faire-sprigsans-regular.woff2",
  },
  {
    name: "Faire Sprig Sans",
    weight: 400,
    style: "italic",
    path: "app/assets/fonts/faire-sprig-sans/faire-sprigsans-regularitalic.woff2",
  },
  {
    name: "Faire Sprig Sans",
    weight: 700,
    style: "normal",
    path: "app/assets/fonts/faire-sprig-sans/faire-sprigsans-bold.woff2",
  },
  {
    name: "Faire Sprig Sans",
    weight: 900,
    style: "normal",
    path: "app/assets/fonts/faire-sprig-sans/faire-sprigsans-black.woff2",
  },
  {
    name: "Maple Mono",
    weight: 400,
    style: "normal",
    path: "app/assets/fonts/maple-mono/maple-mono-nl-regular.woff2",
  },
  {
    name: "Maple Mono",
    weight: 600,
    style: "normal",
    path: "app/assets/fonts/maple-mono/maple-mono-nl-semibold.woff2",
  },
];

export async function loadFonts() {
  return Promise.all(
    fontFiles.map(async ({ name, weight, style, path }) => {
      const woff2 = await readFile(resolve(projectRoot, path));
      const ttf = Buffer.from(await wawoff2.decompress(woff2));
      return { name, weight, style, data: ttf };
    }),
  );
}
