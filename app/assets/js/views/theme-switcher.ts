import type { ViewFn } from "@icelab/defo";

const STORAGE_KEY = "hk-color-scheme";

type Preference = "light" | "dark" | "system";
type Scheme = "light" | "dark";

function getStoredPreference(): Preference {
  const stored = window.localStorage.getItem(STORAGE_KEY);
  if (stored === "light" || stored === "dark") return stored;
  return "system";
}

function setStoredPreference(pref: Preference) {
  if (pref === "system") {
    window.localStorage.removeItem(STORAGE_KEY);
  } else {
    window.localStorage.setItem(STORAGE_KEY, pref);
  }
}

function getSystemScheme(): Scheme {
  return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";
}

function resolveScheme(pref: Preference): Scheme {
  return pref === "system" ? getSystemScheme() : pref;
}

function applyScheme(scheme: Scheme) {
  document.documentElement.classList.toggle("dark", scheme === "dark");
}

function isPreference(value: string | undefined): value is Preference {
  return value === "light" || value === "dark" || value === "system";
}

/**
 * themeSwitcher
 *
 * Three-state theme selector: light, dark, or match system. Stores the user's
 * choice in localStorage as "light"/"dark"; "system" is represented by an
 * absent key so the inline FOUC-prevention script in the layout can fall back
 * to prefers-color-scheme without needing to know about the explicit value.
 *
 * @example
 * <div data-defo-theme-switcher role="radiogroup">
 *   <button data-theme-switcher-option="light">…</button>
 *   <button data-theme-switcher-option="system">…</button>
 *   <button data-theme-switcher-option="dark">…</button>
 *   <span data-theme-switcher-indicator></span>
 * </div>
 */
export const themeSwitcherViewFn: ViewFn = (node: HTMLElement) => {
  const buttons = Array.from(node.querySelectorAll<HTMLButtonElement>("[data-theme-switcher-option]"));

  let preference = getStoredPreference();

  const render = () => {
    buttons.forEach((btn) => {
      const isActive = btn.dataset.themeSwitcherOption === preference;
      btn.setAttribute("aria-checked", isActive ? "true" : "false");
      btn.tabIndex = isActive ? 0 : -1;
    });
    // The indicator's CSS reads from <html>'s data-theme-pref so the inline
    // FOUC script can position it before first paint.
    document.documentElement.dataset.themePref = preference;
  };

  // Sync state that the inline FOUC-prevention script may have already set.
  applyScheme(resolveScheme(preference));
  render();

  const setPreference = (next: Preference) => {
    preference = next;
    setStoredPreference(next);
    applyScheme(resolveScheme(next));
    render();
  };

  const handleClick = (e: MouseEvent) => {
    const target = (e.target as HTMLElement | null)?.closest<HTMLElement>("[data-theme-switcher-option]");
    if (!target) return;
    const next = target.dataset.themeSwitcherOption;
    if (!isPreference(next)) return;
    setPreference(next);
  };

  // Roving-tabindex keyboard support, per the radiogroup ARIA pattern.
  const handleKeyDown = (e: KeyboardEvent) => {
    const keys = ["ArrowLeft", "ArrowRight", "ArrowUp", "ArrowDown", "Home", "End"];
    if (!keys.includes(e.key)) return;
    e.preventDefault();
    const currentIdx = Math.max(
      0,
      buttons.findIndex((b) => b.getAttribute("aria-checked") === "true"),
    );
    let nextIdx = currentIdx;
    if (e.key === "ArrowLeft" || e.key === "ArrowUp") {
      nextIdx = (currentIdx - 1 + buttons.length) % buttons.length;
    } else if (e.key === "ArrowRight" || e.key === "ArrowDown") {
      nextIdx = (currentIdx + 1) % buttons.length;
    } else if (e.key === "Home") {
      nextIdx = 0;
    } else if (e.key === "End") {
      nextIdx = buttons.length - 1;
    }
    const next = buttons[nextIdx]?.dataset.themeSwitcherOption;
    if (!isPreference(next)) return;
    setPreference(next);
    buttons[nextIdx]?.focus();
  };

  // Track OS preference changes when the user is in system mode.
  const mediaQuery = window.matchMedia("(prefers-color-scheme: dark)");
  const handleSystemChange = () => {
    if (preference === "system") {
      applyScheme(resolveScheme(preference));
    }
  };

  node.addEventListener("click", handleClick);
  node.addEventListener("keydown", handleKeyDown);
  mediaQuery.addEventListener("change", handleSystemChange);

  return {
    destroy: () => {
      node.removeEventListener("click", handleClick);
      node.removeEventListener("keydown", handleKeyDown);
      mediaQuery.removeEventListener("change", handleSystemChange);
    },
  };
};
