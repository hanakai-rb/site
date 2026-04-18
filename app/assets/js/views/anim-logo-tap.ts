import type { ViewFn } from "@icelab/defo";

const TAPPED_CLASS = "is-tapped";

/**
 * animLogoTap
 *
 * On touch devices, `:hover` sticks after a tap and blocks the one-shot
 * burst animations from re-triggering. This view watches for touch/pen
 * pointerdown and replays the class so the animation fires every tap.
 *
 * @example
 * <svg class="anim-logo" data-defo-anim-logo-tap>...</svg>
 */
export const animLogoTapViewFn: ViewFn = (node: HTMLElement) => {
  const onPointerDown = (event: PointerEvent) => {
    if (event.pointerType !== "touch" && event.pointerType !== "pen") return;

    node.classList.remove(TAPPED_CLASS);
    // Force a reflow so re-adding the class restarts the animation.
    void node.getBoundingClientRect();
    node.classList.add(TAPPED_CLASS);
  };

  node.addEventListener("pointerdown", onPointerDown);

  return {
    destroy: () => {
      node.removeEventListener("pointerdown", onPointerDown);
    },
  };
};
