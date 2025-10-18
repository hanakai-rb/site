import type { Views } from "@icelab/defo";

import { breakpointFilter } from "~/utils/breakpoints";
import { ensureActiveNavLinkVisibleViewFn } from "./ensure-active-nav-link-visible";
import { lazyLoadView } from "~/utils/lazy-load";
import { mobilePageNavViewFn } from "./mobile-page-nav";
import { sizeToVarViewFn } from "./size-to-var";
import { staticSearchViewFn } from "./static-search";
import { targetCurrentViewFn } from "./target-current";
import { tocScrollViewFn } from "./toc-scroll";
import { toggleClassViewFn } from "./toggle-class";

export const views: Views = {
  ensureActiveNavLinkVisible: ensureActiveNavLinkVisibleViewFn,
  foresight: lazyLoadView(async () => {
    const { foresightViewFn } = await import("./foresight");
    return foresightViewFn;
  }),
  // mobilePageNav: breakpointFilter(mobilePageNavViewFn),
  mobilePageNav: mobilePageNavViewFn,
  sizeToVar: sizeToVarViewFn,
  staticSearch: staticSearchViewFn,
  targetCurrent: targetCurrentViewFn,
  tocScroll: breakpointFilter(tocScrollViewFn),
  toggleClass: toggleClassViewFn,
};
