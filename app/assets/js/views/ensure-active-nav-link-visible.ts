const STORAGE_KEY = `hkActiveNavScroll`;
const EXPIRY_MS = 5000;

/**
 * Ensure active link (the one that matches the current path) is visible on screen. Useful for long
 * navigation lists within scrolling panels.
 */
export const ensureActiveNavLinkVisibleViewFn = (
  container: HTMLElement,
  block: ScrollIntoViewOptions["block"] = "center",
) => {
  const currentPath = window.location.pathname;
  const match = container.querySelector<HTMLAnchorElement>(`a[href="${currentPath}"]`);

  if (match) {
    scrollToMatch({ block, container, match });
  }

  // Record scroll position in sessionStorage when user clicks on a link within our scope.
  const onNavClick = (event: MouseEvent) => {
    const target = event.target as Element | null;
    const anchor = target?.closest && target.closest("a");
    // Only store for same-origin links
    if (!anchor || anchor.origin !== window.location.origin) {
      return;
    }

    sessionStorage.setItem(
      STORAGE_KEY,
      JSON.stringify({
        scrollTop: container.scrollTop,
        timestamp: Date.now(),
      }),
    );
  };

  container.addEventListener("click", onNavClick);

  return {
    destroy: () => {
      container.removeEventListener("click", onNavClick);
    },
  };
};

function scrollToMatch({
  block = "center",
  container,
  match,
}: {
  block: ScrollIntoViewOptions["block"];
  container: HTMLElement;
  match: HTMLAnchorElement;
}) {
  let scrollPosition: number | undefined = undefined;

  // If we recently clicked a link to this path, prefer its stored scrollTop
  try {
    const { scrollTop, timestamp } = JSON.parse(sessionStorage.getItem(STORAGE_KEY) ?? "") as {
      scrollTop: number;
      timestamp: number;
    };
    const delta = Date.now() - timestamp;
    if (delta <= EXPIRY_MS) {
      scrollPosition = scrollTop;
      sessionStorage.removeItem(STORAGE_KEY);
    }
  } catch (_err) {
    // Ignore parse/storage errors and continue with calculated behavior
  }

  if (scrollPosition === undefined) {
    const linkTop = match.offsetTop;
    const linkHeight = match.offsetHeight;
    const containerHeight = container.clientHeight;

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
        }
        break;
      case "center":
      default:
        scrollPosition = linkTop - containerHeight / 2 + linkHeight / 2;
        break;
    }
  }

  if (scrollPosition) {
    container.scrollTop = scrollPosition;
  }
}
