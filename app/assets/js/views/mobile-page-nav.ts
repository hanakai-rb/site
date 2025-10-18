import type { ViewFn } from "@icelab/defo";

type Props = {
  navButtonSelector: string;
  navContainerSelector: string;
  tocButtonSelector: string;
  tocContainerSelector: string;
};

/**
 * mobileNav
 *
 * @example
 * <div data-defo-mobile-nav='{"blockVarName": "--block"}'/>
 */
export const mobilePageNavViewFn: ViewFn<Props> = (
  contextNode,
  { navButtonSelector, navContainerSelector, tocButtonSelector, tocContainerSelector },
) => {
  const tearDownNav = setup({
    contextNode,
    buttonSelector: navButtonSelector,
    containerSelector: navContainerSelector,
  });
  const tearDownToc = setup({
    contextNode,
    buttonSelector: tocButtonSelector,
    containerSelector: tocContainerSelector,
  });

  return {
    destroy: () => {
      tearDownNav();
      tearDownToc();
    },
  };
};

const buttonActiveClasses = ["active"];
const containerActiveClasses = ["active"];

function setup({
  contextNode,
  buttonSelector,
  containerSelector,
}: {
  contextNode: HTMLElement;
  buttonSelector: string;
  containerSelector: string;
}) {
  let active = false;
  const buttonEl = contextNode.querySelector<HTMLElement>(buttonSelector);
  const containerEl = contextNode.querySelector<HTMLElement>(containerSelector);

  if (!buttonEl || !containerEl) {
    return () => {};
  }

  const activate = () => {
    active = true;
    buttonEl.classList.add(...buttonActiveClasses);
    containerEl.classList.add(...containerActiveClasses);
  };

  const deactivate = () => {
    active = false;
    buttonEl.classList.remove(...buttonActiveClasses);
    containerEl.classList.remove(...containerActiveClasses);
  };

  const onButtonClick = () => {
    if (active) {
      deactivate();
    } else {
      activate();
    }
  };

  const onClickAwayContainer = (e: MouseEvent | TouchEvent) => {
    const clickAway =
      e.target &&
      e.target instanceof Node &&
      e.target !== buttonEl &&
      !buttonEl.contains(e.target) &&
      e.target !== containerEl &&
      !containerEl.contains(e.target);
    if (active && clickAway) {
      e.preventDefault();
      deactivate();
    }
  };

  const onContainerClick = (e: MouseEvent) => {
    // Find the closest anchor element to the click target
    const anchor = e.target instanceof Element ? e.target.closest("a") : null;
    // Only deactivate if the anchor is inside the container
    if (anchor && containerEl.contains(anchor)) {
      deactivate();
    }
  };

  // Bind events
  buttonEl.addEventListener("click", onButtonClick);
  containerEl.addEventListener("click", onContainerClick);
  // On touch devices need to use touchstart to register touches for non-interactive elements
  const eventType = "ontouchstart" in window || navigator.maxTouchPoints > 0 ? "touchstart" : "click";
  window.addEventListener(eventType, onClickAwayContainer);

  // Tear down
  return () => {
    buttonEl.removeEventListener("click", onButtonClick);
    containerEl.removeEventListener("click", onContainerClick);
    window.removeEventListener(eventType, onClickAwayContainer);
  };
}

// On toggle
// - Change classes on navButton
// - Change classes on navContainer
// - Lock scroll on htmlElement
// - Toggle focus trap on navContainer
// - Disable scrollwheel?
