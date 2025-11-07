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

    if (pagefindUiSearchInput) {
      pagefindUiSearchInput.focus();
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

  const onActivateClick = async (e: MouseEvent) => {
    await activate();
  };

  const onDeactivateClick = async (e: MouseEvent) => {
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
