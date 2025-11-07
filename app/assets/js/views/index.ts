import type { Views } from "@icelab/defo";

import { breakpointFilter } from "~/utils/breakpoints";
import { ensureActiveNavLinkVisibleViewFn } from "./ensure-active-nav-link-visible";
import { isMacViewFn } from "./is-mac";
import { lazyLoadView } from "~/utils/lazy-load";
import { mobilePageNavViewFn } from "./mobile-page-nav";
import { sizeToVarViewFn } from "./size-to-var";
import { targetCurrentViewFn } from "./target-current";
import { tocScrollViewFn } from "./toc-scroll";
import { toggleClassViewFn } from "./toggle-class";
import { pagefindSearchViewFn } from "./pagefind-search";

export const views: Views = {
  ensureActiveNavLinkVisible: ensureActiveNavLinkVisibleViewFn,
  isMac: isMacViewFn,
  foresight: lazyLoadView(async () => {
    const { foresightViewFn } = await import("./foresight");
    return foresightViewFn;
  }),
  mobilePageNav: breakpointFilter(mobilePageNavViewFn),
  sizeToVar: sizeToVarViewFn,
  pagefindSearch: pagefindSearchViewFn,
  targetCurrent: targetCurrentViewFn,
  tocScroll: breakpointFilter(tocScrollViewFn),
  toggleClass: toggleClassViewFn,
};
