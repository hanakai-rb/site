import type { ViewFn } from "@icelab/defo";

type Props = {
  clickAway?: boolean;
  eventListenerOptions?: AddEventListenerOptions;
  eventName?: keyof WindowEventMap;
  preventDefault?: boolean;
  targetSelector: string;
  targetToggleClassName: string;
  triggerSelector?: string;
  triggerToggleClassName?: string;
};

/**
 * toggleClass
 *
 * Declaratively toggle the class name for a `trigger` and its `targets`.
 *
 * @example
 * <button data-def-toggle-class='{
 *   "targetSelector": "#popover",
 *   "targetToggleClassName": "hidden flex"
 * }'>Toggle</button>
 * <div id="popover" role="popover" class="hidden">
 *   Popover content
 * </div>
 * --> <div id="popover" role="popover" class="flex">
 */
export const toggleClassViewFn: ViewFn<Props> = (
  node: HTMLElement,
  {
    clickAway,
    eventListenerOptions,
    eventName = "click",
    preventDefault = false,
    targetSelector,
    targetToggleClassName,
    triggerSelector,
    triggerToggleClassName,
  }: Props,
) => {
  // Assume we start inactive
  let active = false;
  const trigger = triggerSelector ? node.querySelector(triggerSelector) : node;
  const targets = document.querySelectorAll(targetSelector);

  if (!targetToggleClassName || !trigger || targets.length === 0) return;

  // Split class name values into an array. `classList.toggle` doesn’t support multiple classes in
  // a single call.
  const triggerActiveClassNameList = triggerToggleClassName ? triggerToggleClassName.split(" ") : [];
  const targetActiveClassNameList = targetToggleClassName.split(" ");

  const onToggle = (event: WindowEventMap[typeof eventName]) => {
    if (preventDefault) {
      event.preventDefault();
    }
    if (triggerToggleClassName) {
      triggerActiveClassNameList.forEach((className) => trigger.classList.toggle(className));
    }
    if (targetToggleClassName) {
      targets.forEach((targetNode) =>
        targetActiveClassNameList.forEach((className) => targetNode.classList.toggle(className)),
      );
    }
    active = !active;
  };

  const onClickAway = (event: MouseEvent) => {
    const { target: eventTarget } = event;
    const eventTargetIsNode = eventTarget instanceof Node;

    // Return early if the toggle isn’t active, or we don’t have a target
    if (!active || !eventTargetIsNode) return;
    let activateClickAway = false;

    // Return early if the clicked element is part of the target
    if (trigger === eventTarget || trigger.contains(eventTarget)) {
      return;
    }

    targets.forEach((targetNode) => {
      if (targetNode !== eventTarget && !targetNode.contains(eventTarget)) {
        activateClickAway = true;
      }
    });

    if (activateClickAway) {
      event.preventDefault();
      onToggle(event);
    }
  };

  // Bind events
  trigger.addEventListener(eventName, onToggle, eventListenerOptions);
  if (clickAway) {
    window.addEventListener("click", onClickAway);
  }

  return {
    destroy: () => {
      trigger.removeEventListener(eventName, onToggle);
      if (clickAway) {
        window.removeEventListener("click", onClickAway);
      }
    },
  };
};
