import type { ViewFn } from "@icelab/defo";

type Props = { macClassName?: string };

/**
 * isMac
 *
 * Adds the given className if the element is running on macOS.
 *
 * @example
 * <div data-defo-is-mac='{"macClassName": "mac"}' />
 * --> <div class="mac">
 */
export const isMacViewFn: ViewFn<Props> = (node: HTMLElement, { macClassName = "mac" }: Props) => {
  // Extremely naive check for `mac` in the user agent
  const isMac = /\bmac/gi.test(window.navigator.userAgent);

  if (isMac) {
    node.classList.add(macClassName);
  }

  return {
    destroy: () => {
      if (isMac) {
        node.classList.remove(macClassName);
      }
    },
  };
};
