import type { Views } from "@icelab/defo";

import { breakpointFilter } from "~/utils/breakpoints";
import { lazyLoadView } from "~/utils/lazy-load";
import { ensureActiveNavLinkVisibleViewFn } from "./ensure-active-nav-link-visible";
import { mobilePageNavViewFn } from "./mobile-page-nav";
import { sizeToVarViewFn } from "./size-to-var";
import { staticSearchViewFn } from "./static-search";
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
  tocScroll: breakpointFilter(tocScrollViewFn),
  toggleClass: toggleClassViewFn,
};
