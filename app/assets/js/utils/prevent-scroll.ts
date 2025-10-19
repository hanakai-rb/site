/**
 * Vanilla, dependency-free port of @react-aria/overlays usePreventScroll behavior.
 * This mirrors the upstream logic including iOS handling and scrollbar compensation,
 * but exposes a simple attach/release API instead of a React hook.
 */

export type PreventScrollOptions = {
  /** Whether the scroll lock is disabled. */
  isDisabled?: boolean;
};

// Visual viewport reference used for scrolling inputs into view on iOS.
const visualViewportRef = typeof document !== "undefined" ? (window as any).visualViewport : null;

// Reference count of active locks and a restore function for when the last lock is released.
let preventScrollCount = 0;
let restore: () => void = () => {};

// Public API: acquire a global scroll lock, returns a function to release it.
export function preventScroll(options: PreventScrollOptions = {}): () => void {
  const { isDisabled } = options;

  if (typeof document === "undefined" || isDisabled) {
    return () => {};
  }

  preventScrollCount++;
  if (preventScrollCount === 1) {
    if (isIOS()) {
      restore = preventScrollMobileSafari();
    } else {
      restore = preventScrollStandard();
    }
  }

  let released = false;
  return () => {
    if (released) return;
    released = true;
    preventScrollCount--;
    if (preventScrollCount === 0) {
      restore();
    }
  };
}

export function isScrollLocked(): boolean {
  return preventScrollCount > 0;
}

// Standard browsers: hide overflow and compensate for scrollbar to avoid layout shift.
function preventScrollStandard(): () => void {
  const scrollbarWidth = window.innerWidth - document.documentElement.clientWidth;
  return chain(
    scrollbarWidth > 0 &&
      ("scrollbarGutter" in (document.documentElement.style as any)
        ? setStyle(document.documentElement as any, "scrollbarGutter", "stable")
        : setStyle(document.documentElement as any, "paddingRight", `${scrollbarWidth}px`)),
    setStyle(document.documentElement as any, "overflow", "hidden"),
  );
}

// Mobile Safari specific strategy.
function preventScrollMobileSafari(): () => void {
  let scrollable: Element | null = null;
  let allowTouchMove = false;

  const onTouchStart = (e: TouchEvent) => {
    const target = e.target as Element;
    scrollable = isScrollable(target) ? target : getScrollParent(target, true);
    allowTouchMove = false;

    // Allow adjusting text selection.
    const selection = target.ownerDocument!.defaultView!.getSelection();
    if (selection && !selection.isCollapsed && selection.containsNode(target, true)) {
      allowTouchMove = true;
    }

    // Allow dragging selection handles in focused inputs with a range selected.
    if (
      "selectionStart" in (target as any) &&
      "selectionEnd" in (target as any) &&
      ((target as any).selectionStart as number) < ((target as any).selectionEnd as number) &&
      target.ownerDocument!.activeElement === target
    ) {
      allowTouchMove = true;
    }
  };

  // Inject overscroll-behavior contain to prevent scroll chaining to the window.
  const styleEl = document.createElement("style");
  styleEl.textContent = `\n@layer {\n  * {\n    overscroll-behavior: contain;\n  }\n}`.trim();
  document.head.prepend(styleEl);

  const onTouchMove = (e: TouchEvent) => {
    // Allow pinch zooming.
    if (e.touches.length === 2 || allowTouchMove) {
      return;
    }

    // Prevent scrolling the window.
    if (!scrollable || scrollable === document.documentElement || scrollable === document.body) {
      e.preventDefault();
      return;
    }

    // Work around overscroll-behavior bug when element doesn't overflow.
    if (
      (scrollable as HTMLElement).scrollHeight === (scrollable as HTMLElement).clientHeight &&
      (scrollable as HTMLElement).scrollWidth === (scrollable as HTMLElement).clientWidth
    ) {
      e.preventDefault();
    }
  };

  const onBlur = (e: FocusEvent) => {
    const target = e.target as HTMLElement;
    const relatedTarget = e.relatedTarget as HTMLElement | null;
    if (relatedTarget && willOpenKeyboard(relatedTarget)) {
      relatedTarget.focus({ preventScroll: true });
      scrollIntoViewWhenReady(relatedTarget, willOpenKeyboard(target));
    } else if (!relatedTarget) {
      const focusable = target.parentElement?.closest("[tabindex]") as HTMLElement | null;
      focusable?.focus({ preventScroll: true });
    }
  };

  // Override programmatic focus to scroll into view without scrolling the whole page.
  const originalFocus = HTMLElement.prototype.focus;
  HTMLElement.prototype.focus = function focusOverride(this: HTMLElement, opts?: FocusOptions) {
    const wasKeyboardVisible = document.activeElement != null && willOpenKeyboard(document.activeElement);
    originalFocus.call(this, { ...(opts || {}), preventScroll: true });
    if (!opts || !opts.preventScroll) {
      scrollIntoViewWhenReady(this, wasKeyboardVisible);
    }
  } as any;

  const removeEvents = chain(
    addEvent(document, "touchstart", onTouchStart as any, { passive: false, capture: true }),
    addEvent(document, "touchmove", onTouchMove as any, { passive: false, capture: true }),
    addEvent(document, "blur", onBlur as any, true),
  );

  return () => {
    removeEvents();
    styleEl.remove();
    HTMLElement.prototype.focus = originalFocus;
  };
}

// Helpers ported from @react-aria/utils
function chain(...callbacks: Array<((...args: any[]) => void) | false | null | undefined>): () => void {
  return () => {
    for (const cb of callbacks) {
      if (typeof cb === "function") cb();
    }
  };
}

function setStyle(element: HTMLElement, style: any, value: string): () => void {
  const cur = (element.style as any)[style];
  (element.style as any)[style] = value;
  return () => {
    (element.style as any)[style] = cur;
  };
}

function addEvent(
  target: Document | Window,
  event: string,
  handler: EventListenerOrEventListenerObject,
  options?: boolean | AddEventListenerOptions,
): () => void {
  target.addEventListener(event, handler, options);
  return () => {
    target.removeEventListener(event, handler, options);
  };
}

function scrollIntoViewWhenReady(target: Element, wasKeyboardVisible: boolean) {
  if (wasKeyboardVisible || !visualViewportRef) {
    scrollIntoView(target);
  } else {
    (visualViewportRef as VisualViewport).addEventListener("resize", () => scrollIntoView(target), {
      once: true,
    } as any);
  }
}

function scrollIntoView(target: Element) {
  const root = (document.scrollingElement as Element) || document.documentElement;
  let nextTarget: Element | null = target;
  while (nextTarget && nextTarget !== root) {
    const scrollable = getScrollParent(nextTarget);
    if (scrollable !== document.documentElement && scrollable !== document.body && scrollable !== nextTarget) {
      const scrollableRect = (scrollable as HTMLElement).getBoundingClientRect();
      const targetRect = (nextTarget as HTMLElement).getBoundingClientRect();
      if (
        targetRect.top < scrollableRect.top ||
        targetRect.bottom > scrollableRect.top + (nextTarget as HTMLElement).clientHeight
      ) {
        let bottom = scrollableRect.bottom;
        if (visualViewportRef) {
          const v = visualViewportRef as VisualViewport;
          bottom = Math.min(bottom, v.offsetTop + v.height);
        }
        const adjustment =
          targetRect.top - scrollableRect.top - ((bottom - scrollableRect.top) / 2 - targetRect.height / 2);
        (scrollable as HTMLElement).scrollTo({
          top: Math.max(
            0,
            Math.min(
              (scrollable as HTMLElement).scrollHeight - (scrollable as HTMLElement).clientHeight,
              (scrollable as HTMLElement).scrollTop + adjustment,
            ),
          ),
          behavior: "smooth",
        });
      }
    }
    nextTarget = (scrollable as HTMLElement).parentElement;
  }
}

// Platform and DOM helpers
function testPlatform(re: RegExp): boolean {
  return typeof window !== "undefined" && (window as any).navigator != null
    ? re.test((window as any).navigator["userAgentData"]?.platform || (window as any).navigator.platform)
    : false;
}

function isMac(): boolean {
  return testPlatform(/^Mac/i);
}

function isIPhone(): boolean {
  return testPlatform(/^iPhone/i);
}

function isIPad(): boolean {
  return testPlatform(/^iPad/i) || (isMac() && (navigator as any).maxTouchPoints > 1);
}

function isIOS(): boolean {
  return isIPhone() || isIPad();
}

function willOpenKeyboard(target: Element): boolean {
  const nonTextInputTypes = new Set([
    "checkbox",
    "radio",
    "range",
    "color",
    "file",
    "image",
    "button",
    "submit",
    "reset",
  ]);
  return (
    (target instanceof HTMLInputElement && !nonTextInputTypes.has(target.type)) ||
    target instanceof HTMLTextAreaElement ||
    (target instanceof HTMLElement && (target as HTMLElement).isContentEditable)
  );
}

function isScrollable(node: Element | null, checkForOverflow?: boolean): boolean {
  if (!node) return false;
  const style = window.getComputedStyle(node as Element);
  let scrollable = /(auto|scroll)/.test((style as any).overflow + (style as any).overflowX + (style as any).overflowY);
  if (scrollable && checkForOverflow) {
    const el = node as HTMLElement;
    scrollable = el.scrollHeight !== el.clientHeight || el.scrollWidth !== el.clientWidth;
  }
  return scrollable;
}

function getScrollParent(node: Element, checkForOverflow?: boolean): Element {
  let scrollableNode: Element | null = node;
  if (isScrollable(scrollableNode, checkForOverflow)) {
    scrollableNode = (scrollableNode as HTMLElement).parentElement;
  }
  while (scrollableNode && !isScrollable(scrollableNode, checkForOverflow)) {
    scrollableNode = (scrollableNode as HTMLElement).parentElement;
  }
  return scrollableNode || (document.scrollingElement as Element) || document.documentElement;
}
