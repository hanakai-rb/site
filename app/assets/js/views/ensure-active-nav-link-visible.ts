type Props = ScrollIntoViewOptions;

/**
 * Ensure active link (the one that matches the current path) is visible on screen. Useful for long
 * navigation lists within scrolling panels.
 */
export const ensureActiveNavLinkVisibleViewFn = (
  node: HTMLElement,
  scrollIntoViewOptions: Props = { block: "center", behavior: "instant" },
) => {
  const currentPath = window.location.pathname;
  const matchingLink = node.querySelector(`a[href="${currentPath}"]`);
  if (matchingLink) {
    matchingLink.scrollIntoView(scrollIntoViewOptions);
  }
};
