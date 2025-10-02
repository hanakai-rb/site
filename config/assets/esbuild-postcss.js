import { readFile } from "node:fs/promises";
import postcss from "postcss";
import path from "node:path";

export const postcssPlugin = ({ plugins = [] } = {}) => {
  return {
    name: "postcss",
    setup(build) {
      build.onLoad({ filter: /\.css$/ }, async (args) => {
        const raw = await readFile(args.path, "utf8");
        const rawCss = raw.toString();
        const source = await postcss(plugins).process(rawCss, {
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

        // Add directories declared via Tailwind's `@source` directive in the CSS being processed
        try {
          const root = postcss.parse(rawCss, { from: args.path });
          root.walkAtRules("source", (atRule) => {
            const p = atRule.params?.trim() || "";
            if (!p) return;
            // Support quoted strings and simple unquoted paths. Multiple entries are space- or comma-separated.
            const matches = Array.from(p.matchAll(/"([^"]+)"|'([^']+)'|([^,\s]+)/g));
            for (const m of matches) {
              const val = m[1] || m[2] || m[3];
              if (!val) continue;
              const resolved = path.resolve(path.dirname(args.path), val);
              watchDirs.add(resolved);
            }
          });
        } catch {}

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
