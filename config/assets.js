import * as assets from "hanami-assets";
import tailwindcss from "@tailwindcss/postcss";
import { postcssPlugin } from "./assets/esbuild-postcss.js";

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
