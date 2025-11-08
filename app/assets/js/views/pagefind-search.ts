import type { ViewFn } from "@icelab/defo";

import { loadCSS, loadScript } from "~/utils/load-resource";

// Pagefind doesn’t have type definitions, alas
declare global {
  class PagefindUI {
    constructor(options: {
      autofocus?: boolean;
      element: string | HTMLElement;
      pageSize?: number;
      resetStyles?: boolean;
      showEmptyFilters?: boolean;
      showImages?: boolean;
      subResults?: boolean;
    });
    destroy: () => void;
  }
}

type Props = {
  activeClassNames: string[];
  activateSelectors: string;
  deactivateSelectors: string;
  pagefindUiSelector: string;
};

export const pagefindSearchViewFn: ViewFn<Props> = (
  contextNode: HTMLElement,
  { activateSelectors, activeClassNames, deactivateSelectors, pagefindUiSelector },
) => {
  let initialised = false;
  let active = false;
  let pagefindInstance: PagefindUI;
  let pagefindUiSearchInput: HTMLInputElement | null = null;

  const { activateElements, deactivateElements, pagefindUiElement } = findElements({
    contextNode,
    activateSelectors,
    deactivateSelectors,
    pagefindUiSelector,
  });

  const initialise = async () => {
    if (initialised) {
      return;
    }
    // Load the Pagefind UI assets dynamically. These are generated separately from our asset bundle
    // by Pagefind’s indexing process.
    await Promise.all([loadCSS("/pagefind/pagefind-ui.css"), loadScript("/pagefind/pagefind-ui.js")]);

    // Initialise Pagefind UI. See https://pagefind.app/docs/ui/ for details.
    pagefindInstance = new PagefindUI({
      autofocus: false, // We manage this manually
      element: pagefindUiElement,
      pageSize: 20,
      resetStyles: false,
      showImages: false,
      subResults: true,
      showEmptyFilters: false,
    });
    pagefindUiSearchInput = pagefindUiElement.querySelector("input.pagefind-ui__search-input");
    initialised = true;
  };

  const activate = async () => {
    if (active) {
      return;
    }
    await initialise();
    contextNode.classList.add(...activeClassNames);

    // Insanity needed to stop iOS scrolling when we focus:
    // https://gist.github.com/kiding/72721a0553fa93198ae2bb6eefaa3299
    if (pagefindUiSearchInput) {
      // This needs to be delayed because we’re transitioning the UI in using a discrete transition
      // which means the focus doesn’t work immediately (we can remove the delay if we remove the
      // transition).
      window.setTimeout(() => {
        pagefindUiSearchInput!.style.opacity = "0";
        pagefindUiSearchInput?.focus();
        window.setTimeout(() => {
          pagefindUiSearchInput!.style.opacity = "1";
        });
      }, 100);
    }

    active = true;
  };

  const deactivate = async () => {
    if (!active) {
      return;
    }
    contextNode.classList.remove(...activeClassNames);
    active = false;
  };

  const onActivateClick = async () => {
    await activate();
  };

  const onDeactivateClick = async () => {
    await deactivate();
  };

  const onKeyDown = async (e: KeyboardEvent) => {
    // Activate on Ctrl/Cmd + K
    if (!active && e.metaKey && e.key === "k") {
      await activate();
    }
    // Deactivate on Escape (unless we’re in the search input)
    if (active && e.key === "Escape") {
      // If focused, clear the input but don’t lose focus
      if (
        pagefindUiSearchInput &&
        document.activeElement === pagefindUiSearchInput &&
        pagefindUiSearchInput.value !== ""
      ) {
        // Refocus because Pagefind loses focus here
        window.requestAnimationFrame(() => pagefindUiSearchInput?.focus());
      } else {
        await deactivate();
      }
    }
  };

  activateElements.forEach((el) => el.addEventListener("click", onActivateClick));
  deactivateElements.forEach((el) => el.addEventListener("click", onDeactivateClick));
  // Capture is required to ensure activeElement is correct when we check the handler
  window.addEventListener("keydown", onKeyDown, { capture: true });

  return {
    destroy: () => {
      active = false;
      activateElements.forEach((el) => el.removeEventListener("click", onActivateClick));
      deactivateElements.forEach((el) => el.removeEventListener("click", onDeactivateClick));
      window.removeEventListener("keydown", onKeyDown, { capture: true });
      pagefindInstance.destroy();
    },
  };
};

const findElements = ({
  contextNode,
  activateSelectors,
  deactivateSelectors,
  pagefindUiSelector,
}: { contextNode: HTMLElement } & Pick<Props, "activateSelectors" | "deactivateSelectors" | "pagefindUiSelector">) => {
  const activateElements = document.querySelectorAll<HTMLElement>(activateSelectors);
  const deactivateElements = document.querySelectorAll<HTMLElement>(deactivateSelectors);
  const pagefindUiElement = contextNode.querySelector<HTMLDivElement>(pagefindUiSelector);

  if (!pagefindUiElement) {
    throw new Error("Search element not found in document");
  }

  return {
    activateElements,
    deactivateElements,
    pagefindUiElement,
  };
};
