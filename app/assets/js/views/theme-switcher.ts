import type { ViewFn } from "@icelab/defo";

const STORAGE_KEY = "hk-color-scheme";

type ColorScheme = "dark" | "light";

function getSystemScheme(): ColorScheme {
  return window.matchMedia("(prefers-color-scheme: dark)").matches
    ? "dark"
    : "light";
}

function getEffectiveScheme(): ColorScheme {
  const stored = window.localStorage.getItem(STORAGE_KEY);
  if (stored === "dark" || stored === "light") return stored;
  return getSystemScheme();
}

function applyScheme(scheme: ColorScheme, isForced: boolean) {
  const html = document.documentElement;
  html.classList.toggle("dark", scheme === "dark");
  if (isForced) {
    html.dataset.colorScheme = scheme;
  } else {
    delete html.dataset.colorScheme;
  }
}

function updateButton(node: HTMLElement, scheme: ColorScheme) {
  node.setAttribute(
    "aria-label",
    scheme === "dark" ? "Switch to light mode" : "Switch to dark mode",
  );
  node.setAttribute("aria-pressed", scheme === "dark" ? "true" : "false");
}

/**
 * themeSwitcher
 *
 * Toggles between dark and light colour schemes. Reads the user's saved
 * preference from localStorage; falls back to prefers-color-scheme. Sets
 * data-color-scheme and the .dark class on <html> so both CSS custom
 * properties and Tailwind dark: utilities respond correctly.
 *
 * @example
 * <button data-defo-theme-switcher />
 */
export const themeSwitcherViewFn: ViewFn = (node: HTMLElement) => {
  let stored = window.localStorage.getItem(STORAGE_KEY) as ColorScheme | null;
  let scheme = getEffectiveScheme();

  // Sync state that the inline FOUC-prevention script may have already set.
  applyScheme(scheme, stored !== null);
  updateButton(node, scheme);

  const handleClick = () => {
    scheme = scheme === "dark" ? "light" : "dark";
    window.localStorage.setItem(STORAGE_KEY, scheme);
    stored = scheme;
    applyScheme(scheme, true);
    updateButton(node, scheme);
  };

  // Track OS preference changes when the user hasn't made an explicit choice.
  const mediaQuery = window.matchMedia("(prefers-color-scheme: dark)");
  const handleSystemChange = (e: MediaQueryListEvent) => {
    if (window.localStorage.getItem(STORAGE_KEY) === null) {
      scheme = e.matches ? "dark" : "light";
      applyScheme(scheme, false);
      updateButton(node, scheme);
    }
  };

  node.addEventListener("click", handleClick);
  mediaQuery.addEventListener("change", handleSystemChange);

  return {
    destroy: () => {
      node.removeEventListener("click", handleClick);
      mediaQuery.removeEventListener("change", handleSystemChange);
    },
  };
};
