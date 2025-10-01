import * as assets from "hanami-assets";
import { readFile } from "node:fs/promises";
import postcss from "postcss";
import tailwindcss from "@tailwindcss/postcss";
import path from "node:path";

const postcssPlugin = ({ plugins = [], extraWatchDirs = [] } = {}) => {
  return {
    name: "postcss",
    setup(build) {
      build.onLoad({ filter: /\.css$/ }, async (args) => {
        const raw = await readFile(args.path, "utf8");
        const source = await postcss(plugins).process(raw.toString(), {
          from: args.path,
        });

        // Collect dependency hints from PostCSS messages (e.g. from Tailwind)
        // so esbuild's watcher knows when to rebuild.
        const watchFiles = new Set();
        const watchDirs = new Set();

        if (Array.isArray(source.messages)) {
          for (const msg of source.messages) {
            // Standard PostCSS dependency messages
            if (msg?.type === "dependency" && msg.file) {
              watchFiles.add(path.resolve(path.dirname(args.path), msg.file));
            } else if (msg?.type === "dir-dependency" && msg.dir) {
              watchDirs.add(path.resolve(path.dirname(args.path), msg.dir));
            }
          }
        }

        // Ensure any extra watch directories are included (e.g. template dirs referenced via @source)
        for (const dir of extraWatchDirs) {
          if (dir) watchDirs.add(path.resolve(dir));
        }
        return {
          contents: source.css,
          loader: "css",
          // Let esbuild know what to watch during `--watch`
          watchFiles: Array.from(watchFiles),
          watchDirs: Array.from(watchDirs),
        };
      });
    },
  };
};

// To provide additional esbuild (https://esbuild.github.io) options, use the following:
//
// Read more at: https://guides.hanamirb.org/assets/customization/
await assets.run({
  esbuildOptionsFn: (args, esbuildOptions) => {
    // Add to esbuildOptions here. Use `args.watch` as a condition for different options for
    // compile vs watch.
    esbuildOptions = {
      ...esbuildOptions,
      format: "esm",
      splitting: true,
      plugins: [
        ...esbuildOptions.plugins,
        postcssPlugin({
          plugins: [tailwindcss],
          // Ensure changes under app/templates trigger rebuilds while watching
          extraWatchDirs: [path.resolve(process.cwd(), "app/templates")],
        }),
      ],
    };

    return esbuildOptions;
  },
});
