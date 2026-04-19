import type { ViewFn } from "@icelab/defo";

type Props = {
  triggerSelector?: string;
};

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
 * Pass `triggerSelector` to listen on an ancestor element instead of the
 * logo itself — handy when the logo sits next to a title and both should
 * trigger the animation together.
 *
 * @example
 * <svg class="anim-logo" data-defo-anim-logo-tap>...</svg>
 * <a class="logo-card">
 *   <svg class="anim-logo" data-defo-anim-logo-tap='{"triggerSelector":".logo-card"}'>...</svg>
 *   <h2>Hanakai</h2>
 * </a>
 */
export const animLogoTapViewFn: ViewFn<Props> = (node: HTMLElement, { triggerSelector }: Props = {}) => {
  const trigger: HTMLElement = triggerSelector ? (node.closest<HTMLElement>(triggerSelector) ?? node) : node;
  let timer: number | null = null;

  const clear = () => {
    if (timer !== null) {
      window.clearTimeout(timer);
      timer = null;
    }
    node.classList.remove(TAPPED_CLASS);
  };

  const fire = () => {
    if (node.classList.contains(TAPPED_CLASS)) return;
    void node.getBoundingClientRect();
    node.classList.add(TAPPED_CLASS);
    timer = window.setTimeout(clear, BURST_DURATION_MS);
  };

  const onPointerEnter = (event: PointerEvent) => {
    if (event.pointerType !== "mouse") return;
    fire();
  };

  const onPointerDown = (event: PointerEvent) => {
    if (event.pointerType !== "touch" && event.pointerType !== "pen") return;
    fire();
  };

  trigger.addEventListener("pointerenter", onPointerEnter);
  trigger.addEventListener("pointerdown", onPointerDown);

  return {
    destroy: () => {
      trigger.removeEventListener("pointerenter", onPointerEnter);
      trigger.removeEventListener("pointerdown", onPointerDown);
      if (timer !== null) window.clearTimeout(timer);
    },
  };
};
