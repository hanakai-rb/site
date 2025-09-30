import type { Views } from "@icelab/defo";

import { breakpointFilter } from "~/utils/breakpoints";
import { lazyLoadView } from "~/utils/lazy-load";
import { docsearchViewFn } from "./docsearch/docsearch";
import { sizeToVarViewFn } from "./size-to-var";
import { tocScrollViewFn } from "./toc-scroll";
import { toggleClassViewFn } from "./toggle-class";

export const views: Views = {
  docsearch: docsearchViewFn,
  sizeToVar: sizeToVarViewFn,
  tocScroll: breakpointFilter(tocScrollViewFn),
  toggleClass: toggleClassViewFn,
  foresight: lazyLoadView(async () => {
    const { foresightViewFn } = await import("./foresight");
    return foresightViewFn;
  }),
};
