import type { Views } from "@icelab/defo";

import { breakpointFilter } from "~/utils/breakpoints";
import { lazyLoadView } from "~/utils/lazy-load";
import { docsearchViewFn } from "./docsearch";
import { ensureActiveNavLinkVisibleViewFn } from "./ensure-active-nav-link-visible";
import { mobilePageNavViewFn } from "./mobile-page-nav";
import { sizeToVarViewFn } from "./size-to-var";
import { targetCurrentViewFn } from "./target-current";
import { tocScrollViewFn } from "./toc-scroll";
import { toggleClassViewFn } from "./toggle-class";

export const views: Views = {
  docsearch: docsearchViewFn,
  ensureActiveNavLinkVisible: ensureActiveNavLinkVisibleViewFn,
  // mobilePageNav: breakpointFilter(mobilePageNavViewFn),
  mobilePageNav: mobilePageNavViewFn,
  sizeToVar: sizeToVarViewFn,
  targetCurrent: targetCurrentViewFn,
  tocScroll: breakpointFilter(tocScrollViewFn),
  toggleClass: toggleClassViewFn,
  foresight: lazyLoadView(async () => {
    const { foresightViewFn } = await import("./foresight");
    return foresightViewFn;
  }),
};
