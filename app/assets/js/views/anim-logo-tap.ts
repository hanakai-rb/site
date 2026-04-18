import type { ViewFn } from "@icelab/defo";

const TAPPED_CLASS = "is-tapped";
// Covers the longest hover choreography (--wiggle-dur + --burst-dur + tail)
// with headroom. See app/assets/css/animated-logos.css.
const BURST_DURATION_MS = 1600;

/**
 * animLogoTap
 *
 * Drives the one-shot burst animations from a class so moving the pointer
 * away mid-animation doesn't cut it off (which causes a flicker on re-entry).
 * While the class is present, further triggers are ignored — the animation
 * always runs to completion before another can start.
 *
 * @example
 * <svg class="anim-logo" data-defo-anim-logo-tap>...</svg>
 */
export const animLogoTapViewFn: ViewFn = (node: HTMLElement) => {
  let timer: number | null = null;

  const clear = () => {
    if (timer !== null) {
      window.clearTimeout(timer);
      timer = null;
    }
    node.classList.remove(TAPPED_CLASS);
  };

  const trigger = () => {
    if (node.classList.contains(TAPPED_CLASS)) return;
    void node.getBoundingClientRect();
    node.classList.add(TAPPED_CLASS);
    timer = window.setTimeout(clear, BURST_DURATION_MS);
  };

  const onPointerEnter = (event: PointerEvent) => {
    if (event.pointerType !== "mouse") return;
    trigger();
  };

  const onPointerDown = (event: PointerEvent) => {
    if (event.pointerType !== "touch" && event.pointerType !== "pen") return;
    trigger();
  };

  node.addEventListener("pointerenter", onPointerEnter);
  node.addEventListener("pointerdown", onPointerDown);

  return {
    destroy: () => {
      node.removeEventListener("pointerenter", onPointerEnter);
      node.removeEventListener("pointerdown", onPointerDown);
      if (timer !== null) window.clearTimeout(timer);
    },
  };
};
