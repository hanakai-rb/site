import type { ViewFn } from "@icelab/defo";
import { createFocusTrap } from "focus-trap";

import { loadCSS, loadScript } from "~/utils/load-resource";
import { preventScroll } from "~/utils/prevent-scroll";

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
      openFilters: string[];
      processResult: (result: any) => typeof result;
    });
    destroy: () => void;
    triggerSearch: (term: string) => void;
    triggerFilters: (filters: Record<string, string>) => void;
  }
}

type Props = {
  activeClassNames: string[];
  activateSelectors: string;
  deactivateSelectors: string;
  pagefindUiSelector: string;
};

const LOCALSTORAGE_KEY = "hk-pagefind-search";
const EXPIRY_MS = 60 * 60 * 1000;

export const pagefindSearchViewFn: ViewFn<Props> = (
  contextNode: HTMLElement,
  { activateSelectors, activeClassNames, deactivateSelectors, pagefindUiSelector },
) => {
  let initialised = false;
  let active = false;
  let releaseScroll: (() => void) | null = null;
  let pagefindInstance: PagefindUI;
  let pagefindUiForm: HTMLFormElement | null = null;
  let pagefindUiSearchInput: HTMLInputElement | null = null;
  const focusTrap = createFocusTrap(contextNode, { escapeDeactivates: false });

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

    const cachedState = retrieveSearchStateCache();

    // Initialise Pagefind UI. See https://pagefind.app/docs/ui/ for details.
    pagefindInstance = new PagefindUI({
      autofocus: false, // We manage this manually
      element: pagefindUiElement,
      pageSize: 20,
      resetStyles: false,
      showImages: false,
      subResults: true,
      showEmptyFilters: false,
      openFilters: cachedState ? [...Object.keys(cachedState.filters)] : [],
      processResult: (result) => {
        result.url = result.url.replace(/\.html$/, "");
        return result;
      },
    });
    pagefindUiForm = pagefindUiElement.querySelector("form.pagefind-ui__form");
    pagefindUiSearchInput = pagefindUiElement.querySelector("input.pagefind-ui__search-input");
    if (cachedState) {
      const { filters, search } = cachedState;
      pagefindInstance.triggerFilters(filters);
      pagefindInstance.triggerSearch(search);
    }
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
        focusTrap.activate();
        pagefindUiSearchInput!.style.opacity = "0";
        pagefindUiSearchInput?.focus();
        window.setTimeout(() => {
          pagefindUiSearchInput!.style.opacity = "1";
        });
      }, 100);
    }

    if (!releaseScroll) {
      releaseScroll = preventScroll();
    }
    active = true;
  };

  const deactivate = async () => {
    if (!active) {
      return;
    }
    contextNode.classList.remove(...activeClassNames);

    if (releaseScroll) {
      releaseScroll();
      releaseScroll = null;
    }
    focusTrap.deactivate();
    active = false;
  };

  const saveSearchStateCache = () => {
    const search = pagefindUiSearchInput?.value;
    const filters = pagefindUiForm ? Object.fromEntries(new FormData(pagefindUiForm)) : {};
    window.localStorage.setItem(LOCALSTORAGE_KEY, JSON.stringify({ filters, search, timestamp: Date.now() }));
  };

  const retrieveSearchStateCache = () => {
    try {
      const data = window.localStorage.getItem(LOCALSTORAGE_KEY);
      const { timestamp, ...rest } = JSON.parse(data!) as {
        filters: Record<string, string>;
        search: string;
        timestamp: number;
      };
      if (Date.now() - timestamp < EXPIRY_MS) {
        return rest;
      }
    } catch {
      // Do nothing
    }
    return undefined;
  };

  const onActivateClick = async () => {
    await activate();
  };

  const onDeactivateClick = async () => {
    saveSearchStateCache();
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
  window.addEventListener("unload", saveSearchStateCache);

  return {
    destroy: () => {
      active = false;
      activateElements.forEach((el) => el.removeEventListener("click", onActivateClick));
      deactivateElements.forEach((el) => el.removeEventListener("click", onDeactivateClick));
      window.removeEventListener("keydown", onKeyDown, { capture: true });
      pagefindInstance.destroy();
      focusTrap.deactivate();
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
