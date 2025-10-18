import type { Views } from "@icelab/defo";

import { breakpointFilter } from "~/utils/breakpoints";
import { lazyLoadView } from "~/utils/lazy-load";
import { docsearchViewFn } from "./docsearch";
import { ensureActiveNavLinkVisibleViewFn } from "./ensure-active-nav-link-visible";
import { sizeToVarViewFn } from "./size-to-var";
import { staticSearchViewFn } from "./static-search";
import { tocScrollViewFn } from "./toc-scroll";
import { toggleClassViewFn } from "./toggle-class";

export const views: Views = {
  docsearch: docsearchViewFn,
  ensureActiveNavLinkVisible: ensureActiveNavLinkVisibleViewFn,
  foresight: lazyLoadView(async () => {
    const { foresightViewFn } = await import("./foresight");
    return foresightViewFn;
  }),
  sizeToVar: sizeToVarViewFn,
  staticSearch: staticSearchViewFn,
  tocScroll: breakpointFilter(tocScrollViewFn),
  toggleClass: toggleClassViewFn,
};
