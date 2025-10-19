import type { ViewFn, ViewFnReturnValue } from "@icelab/defo";

export type Breakpoint = "sm" | "md" | "lg" | "xl" | "2xl";
export type BreakpointComparator = ">=" | ">" | "<" | "<=" | "=";
export type BreakpointQuery = Breakpoint | { breakpoint: Breakpoint; comparator: BreakpointComparator };

// These match Tailwind’s default breakpoints: https://tailwindcss.com/docs/responsive-design
const breakpointMap: Record<Breakpoint, string> = {
  sm: "40rem",
  md: "48rem",
  lg: "64rem",
  xl: "80rem",
  "2xl": "96rem",
};

const breakpointNames = Object.keys(breakpointMap) as Breakpoint[];

function createMediaQueryString(input: BreakpointQuery): string {
  const { breakpoint, comparator } =
    typeof input === "string" ? { breakpoint: input, comparator: ">=" as BreakpointComparator } : input;
  const width = breakpointMap[breakpoint];
  return `(width ${comparator} ${width})`;
}

/**
 * Returns the current breakpoint match status for all defined breakpoints.
 * Useful for checking which breakpoints are currently active.
 */
export function breakpointMatches(): Record<Breakpoint, boolean> {
  const matches: Record<Breakpoint, boolean> = {
    sm: false,
    md: false,
    lg: false,
    xl: false,
    "2xl": false,
  };

  breakpointNames.forEach((breakpoint: Breakpoint) => {
    const mediaQuery = createMediaQueryString(breakpoint);
    matches[breakpoint] = window.matchMedia(mediaQuery).matches;
  });

  return matches;
}

/**
 * Higher-order function that wraps a Defo view function to only activate when specified breakpoints match.
 *
 * @param viewFn - The Defo view function to wrap
 * @returns A new view function that respects breakpoint matching
 *
 * @example
 * const responsiveView = breakpointFilter(myViewFn);
 * // Usage: <div data-defo-my-view='{"breakpoints": ["md", "lg"], ...otherProps}'></div>
 */
export function breakpointFilter<T extends Record<string, unknown>>(viewFn: ViewFn<T>) {
  return (node: HTMLElement, props: { breakpoints: BreakpointQuery[] } & T) => {
    const { breakpoints, ...restProps } = props;
    const mediaQueries = breakpoints.map(createMediaQueryString).join(", ");
    const mediaQueryList = window.matchMedia(mediaQueries);

    let activeViewInstance: ViewFnReturnValue<T> | null = null;
    let mediaQueryListener: ((event: MediaQueryListEvent) => void) | null = null;

    async function activateView(): Promise<void> {
      if (activeViewInstance) {
        // Already active
        return;
      }

      const result = viewFn(node, restProps as any);
      activeViewInstance = result instanceof Promise ? await result : result;
    }

    function deactivateView(): void {
      if (activeViewInstance === null) {
        // Already inactive
        return;
      }

      activeViewInstance?.destroy && activeViewInstance.destroy();
      activeViewInstance = null;
    }

    function handleMediaQueryChange(event: MediaQueryListEvent): void {
      if (event.matches) {
        activateView();
      } else {
        deactivateView();
      }
    }

    // Set up media query listener
    mediaQueryListener = handleMediaQueryChange;
    mediaQueryList.addEventListener("change", mediaQueryListener);

    // Activate immediately if breakpoint currently matches
    if (mediaQueryList.matches) {
      activateView();
    }

    return {
      update: (newProps: T, prevProps: T) => {
        // Only forward update calls to the active view instance
        if (activeViewInstance?.update) {
          activeViewInstance.update(newProps, prevProps);
        }
      },
      destroy: () => {
        // Clean up media query listener
        if (mediaQueryListener) {
          mediaQueryList.removeEventListener("change", mediaQueryListener);
          mediaQueryListener = null;
        }
        // Deactivate the view if it's currently active
        deactivateView();
      },
    };
  };
}
