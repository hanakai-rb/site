import type { ViewFn } from "@icelab/defo";

const COPIED_CLASS = "is-copied";
const COPIED_LABEL = "Copied";
const RESET_MS = 1500;

/**
 * copyCode
 *
 * Bound to a node that contains a `<button>` and a `<pre>`. Clicking
 * the button copies the pre's text content to the clipboard and briefly
 * marks the button as `.is-copied` so CSS can swap the icon.
 *
 * @example
 * <div data-defo-copy-code>
 *   <button type="button">Copy</button>
 *   <pre>Code that will be copied</pre>
 * </div>
 */
export const copyCodeViewFn: ViewFn = (node: HTMLElement) => {
  const button = node.querySelector("button");
  const pre = node.querySelector("pre");

  if (!button || !pre) return;

  const originalLabel = button.getAttribute("aria-label");
  let resetTimer: ReturnType<typeof setTimeout> | undefined;

  const markCopied = () => {
    button.classList.add(COPIED_CLASS);
    button.setAttribute("aria-label", COPIED_LABEL);

    if (resetTimer) clearTimeout(resetTimer);
    resetTimer = setTimeout(() => {
      button.classList.remove(COPIED_CLASS);
      if (originalLabel !== null) {
        button.setAttribute("aria-label", originalLabel);
      } else {
        button.removeAttribute("aria-label");
      }
    }, RESET_MS);
  };

  const handleClick = async () => {
    const text = pre.textContent ?? "";
    try {
      await navigator.clipboard.writeText(text);
      markCopied();
    } catch {
      // Clipboard API can reject when the document isn't focused or the
      // permission is denied; swallow so the UI doesn't blow up.
    }
  };

  button.addEventListener("click", handleClick);

  return {
    destroy: () => {
      button.removeEventListener("click", handleClick);
      if (resetTimer) clearTimeout(resetTimer);
    },
  };
};
