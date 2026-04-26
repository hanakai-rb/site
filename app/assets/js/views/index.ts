import type { Views } from "@icelab/defo";

import { breakpointFilter } from "~/utils/breakpoints";
import { animLogoTapViewFn } from "./anim-logo-tap";
import { copyCodeViewFn } from "./copy-code";
import { dismissibleBannerViewFn } from "./dismissible-banner";
import { ensureActiveNavLinkVisibleViewFn } from "./ensure-active-nav-link-visible";
import { overflowClassViewFn } from "./overflow-class";
import { lazyLoadView } from "~/utils/lazy-load";
import { mobilePageNavViewFn } from "./mobile-page-nav";
import { replaceWithTemplateViewFn } from "./replace-with-template";
import { sizeToVarViewFn } from "./size-to-var";
import { targetCurrentViewFn } from "./target-current";
import { tocScrollViewFn } from "./toc-scroll";
import { themeSwitcherViewFn } from "./theme-switcher";
import { toggleClassViewFn } from "./toggle-class";

export const views: Views = {
  animLogoTap: animLogoTapViewFn,
  copyCode: copyCodeViewFn,
  dismissibleBanner: dismissibleBannerViewFn,
  ensureActiveNavLinkVisible: ensureActiveNavLinkVisibleViewFn,
  foresight: lazyLoadView(async () => {
    const { foresightViewFn } = await import("./foresight");
    return foresightViewFn;
  }),
  mobilePageNav: breakpointFilter(mobilePageNavViewFn),
  overflowClass: overflowClassViewFn,
  replaceWithTemplate: replaceWithTemplateViewFn,
  sizeToVar: sizeToVarViewFn,
  pagefindSearch: lazyLoadView(async () => {
    const { pagefindSearchViewFn } = await import("./pagefind-search");
    return pagefindSearchViewFn;
  }),
  targetCurrent: targetCurrentViewFn,
  themeSwitcher: themeSwitcherViewFn,
  tocScroll: breakpointFilter(tocScrollViewFn),
  toggleClass: toggleClassViewFn,
};
