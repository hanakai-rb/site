/**
 * Ensure active link (the one that matches the current path) is visible on screen. Useful for long
 * navigation lists within scrolling panels.
 */
export const ensureActiveNavLinkVisibleViewFn = (
  node: HTMLElement,
  block: ScrollIntoViewOptions["block"] = "center",
) => {
  const currentPath = window.location.pathname;
  const matchingLink = node.querySelector<HTMLElement>(`a[href="${currentPath}"]`);

  if (matchingLink) {
    const container = node;
    const linkTop = matchingLink.offsetTop;
    const linkHeight = matchingLink.offsetHeight;
    const containerHeight = container.clientHeight;

    let scrollPosition: number;

    switch (block) {
      case "start":
        scrollPosition = linkTop;
        break;
      case "end":
        scrollPosition = linkTop - containerHeight + linkHeight;
        break;
      case "nearest":
        // Only scroll if not already visible
        const currentScroll = container.scrollTop;
        const linkBottom = linkTop + linkHeight;
        const containerBottom = currentScroll + containerHeight;

        if (linkTop < currentScroll) {
          scrollPosition = linkTop;
        } else if (linkBottom > containerBottom) {
          scrollPosition = linkTop - containerHeight + linkHeight;
        } else {
          return; // Already visible
        }
        break;
      case "center":
      default:
        scrollPosition = linkTop - containerHeight / 2 + linkHeight / 2;
        break;
    }

    container.scrollTop = scrollPosition;
  }
};
