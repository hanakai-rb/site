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
  // We manage initial focus ourselves (synchronously, inside the click handler) so that iOS
  // Safari sees the focus() call as part of the user gesture and raises the virtual keyboard.
  const focusTrap = createFocusTrap(contextNode, {
    escapeDeactivates: false,
    initialFocus: false,
  });

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
    // Flip the flag early so concurrent calls (e.g. eager pre-init + first click) don’t double up.
    initialised = true;
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
  };

  // iOS Safari only shows the virtual keyboard when focus() is called synchronously inside a user
  // gesture, so we eagerly load Pagefind in the background. That way the input exists in the DOM
  // by the time the user taps the search button and we can focus it without an async boundary.
  const initialisePromise =
    "requestIdleCallback" in window
      ? new Promise<void>((resolve) => {
          window.requestIdleCallback(() => initialise().then(resolve));
        })
      : initialise();

  const focusSearchInput = () => {
    if (!pagefindUiSearchInput) return;
    // Insanity needed to stop iOS scrolling when we focus:
    // https://gist.github.com/kiding/72721a0553fa93198ae2bb6eefaa3299
    pagefindUiSearchInput.style.opacity = "0";
    pagefindUiSearchInput.focus();
    window.requestAnimationFrame(() => {
      if (pagefindUiSearchInput) pagefindUiSearchInput.style.opacity = "1";
    });
    focusTrap.activate();
  };

  const activate = () => {
    if (active) {
      return;
    }
    active = true;
    // `inert` is on the dialog by default so it can’t be focused or clicked while hidden. Remove
    // it before we focus, synchronously, so the input is focusable inside the click gesture.
    contextNode.removeAttribute("inert");
    contextNode.classList.add(...activeClassNames);

    if (!releaseScroll) {
      releaseScroll = preventScroll();
    }

    if (pagefindUiSearchInput) {
      focusSearchInput();
    } else {
      // First interaction before eager init finished — focus once Pagefind is ready. iOS won’t
      // raise the keyboard on this path (it’s outside the gesture) but subsequent taps will.
      initialisePromise.then(() => {
        if (active) focusSearchInput();
      });
    }
  };

  const deactivate = () => {
    if (!active) {
      return;
    }
    contextNode.classList.remove(...activeClassNames);
    contextNode.setAttribute("inert", "");

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

  const onActivateClick = () => {
    activate();
  };

  const onDeactivateClick = () => {
    saveSearchStateCache();
    deactivate();
  };

  const onKeyDown = (e: KeyboardEvent) => {
    // Activate on Ctrl/Cmd + K
    if (!active && e.metaKey && e.key === "k") {
      activate();
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
        deactivate();
      }
    }
  };

  // iOS Safari doesn’t fire `unload`, so rely on `pagehide` (which does) and `visibilitychange` on
  // mobile backgrounding to make sure we actually persist the search state.
  const onPageHide = () => saveSearchStateCache();
  const onVisibilityChange = () => {
    if (document.visibilityState === "hidden") saveSearchStateCache();
  };

  activateElements.forEach((el) => el.addEventListener("click", onActivateClick));
  deactivateElements.forEach((el) => el.addEventListener("click", onDeactivateClick));
  // Capture is required to ensure activeElement is correct when we check the handler
  window.addEventListener("keydown", onKeyDown, { capture: true });
  window.addEventListener("pagehide", onPageHide);
  document.addEventListener("visibilitychange", onVisibilityChange);

  return {
    destroy: () => {
      active = false;
      activateElements.forEach((el) => el.removeEventListener("click", onActivateClick));
      deactivateElements.forEach((el) => el.removeEventListener("click", onDeactivateClick));
      window.removeEventListener("keydown", onKeyDown, { capture: true });
      window.removeEventListener("pagehide", onPageHide);
      document.removeEventListener("visibilitychange", onVisibilityChange);
      pagefindInstance?.destroy();
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
