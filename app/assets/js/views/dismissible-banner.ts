import type { ViewFn } from "@icelab/defo";

const STORAGE_PREFIX = "hk-banner-dismissed:";

type Props = { id: string; dismissSelector?: string };

/**
 * dismissibleBanner
 *
 * Announcement banner that hides itself when the user clicks a child
 * dismiss button. Persists the dismissal in localStorage so the banner
 * stays hidden on return visits. An inline script in the partial handles
 * the initial hide (FOUC-free) by reading the same key.
 *
 * @example
 * <div data-defo-dismissible-banner='{"id":"hanakai"}'>
 *   <a href="/post">...</a>
 *   <button data-dismiss>Dismiss</button>
 * </div>
 */
export const dismissibleBannerViewFn: ViewFn<Props> = (
  node: HTMLElement,
  { id, dismissSelector = "button" }: Props,
) => {
  const key = STORAGE_PREFIX + id;
  const dismissButton = node.querySelector<HTMLButtonElement>(dismissSelector);

  const handleClick = (event: Event) => {
    event.preventDefault();
    window.localStorage.setItem(key, "true");
    node.classList.add("hidden");
  };
  dismissButton?.addEventListener("click", handleClick);

  return {
    destroy: () => {
      dismissButton?.removeEventListener("click", handleClick);
    },
  };
};
