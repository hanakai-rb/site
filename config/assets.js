import * as assets from "hanami-assets";
import { readFile } from "node:fs/promises";
import postcss from "postcss";
import tailwindcss from "@tailwindcss/postcss";

const postcssPlugin = ({ plugins = [] } = {}) => {
  return {
    name: "postcss",
    setup(build) {
      build.onLoad({ filter: /\.css$/ }, async (args) => {
        const raw = await readFile(args.path, "utf8");
        const source = await postcss(plugins).process(raw.toString(), {
          from: args.path,
        });
        return {
          contents: source.css,
          loader: "css",
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
        }),
      ],
    };

    return esbuildOptions;
  },
});
