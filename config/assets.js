import * as assets from "hanami-assets";
import tailwindcss from "@tailwindcss/postcss";
import { postcssPlugin } from "./assets/esbuild-postcss.js";

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
