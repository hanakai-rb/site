import { beforeAll, beforeEach, afterEach, expect, test, describe, vi } from "vitest";
import { breakpointFilter, breakpointMatches, type Breakpoint, type BreakpointQuery } from "./breakpoints";

// Mock MediaQueryList
class MockMediaQueryList {
  matches: boolean;
  listeners: ((event: MediaQueryListEvent) => void)[] = [];

  constructor(matches = false) {
    this.matches = matches;
  }

  addEventListener(type: string, listener: (event: MediaQueryListEvent) => void) {
    if (type === "change") {
      this.listeners.push(listener);
    }
  }

  removeEventListener(type: string, listener: (event: MediaQueryListEvent) => void) {
    if (type === "change") {
      const index = this.listeners.indexOf(listener);
      if (index > -1) {
        this.listeners.splice(index, 1);
      }
    }
  }

  // Helper method to simulate media query changes
  simulateChange(matches: boolean) {
    this.matches = matches;
    const event = { matches } as MediaQueryListEvent;
    this.listeners.forEach((listener) => listener(event));
  }
}

// Mock window.matchMedia
const mockMatchMedia = vi.fn();

beforeAll(() => {
  const originalMatchMedia = window.matchMedia;
  window.matchMedia = mockMatchMedia;
  return () => {
    window.matchMedia = originalMatchMedia;
  };
});

beforeEach(() => {
  mockMatchMedia.mockClear();
});

afterEach(() => {
  vi.clearAllMocks();
});

test("creates a wrapped view function that respects breakpoint matching", () => {
  const mockViewFn = vi.fn().mockReturnValue({
    destroy: vi.fn(),
    update: vi.fn(),
  });

  const mockMediaQueryList = new MockMediaQueryList(true);
  mockMatchMedia.mockReturnValue(mockMediaQueryList);

  const wrappedViewFn = breakpointFilter(mockViewFn);
  const node = document.createElement("div");
  const props = { breakpoints: ["md", "lg"], someOtherProp: "value" } satisfies {
    breakpoints: Breakpoint[];
  } & Record<string, unknown>;

  const result = wrappedViewFn(node, props);

  // Should call matchMedia with correct query
  expect(mockMatchMedia).toHaveBeenCalledWith("(width >= 48rem), (width >= 64rem)");

  // Should call the original view function when media query matches
  expect(mockViewFn).toHaveBeenCalledWith(node, { someOtherProp: "value" });

  // Should return destroy and update functions
  expect(result).toHaveProperty("destroy");
  expect(result).toHaveProperty("update");
  expect(typeof result.destroy).toBe("function");
  expect(typeof result.update).toBe("function");
});

test("does not call view function when breakpoint does not match initially", () => {
  const mockViewFn = vi.fn().mockReturnValue({
    destroy: vi.fn(),
  });

  const mockMediaQueryList = new MockMediaQueryList(false);
  mockMatchMedia.mockReturnValue(mockMediaQueryList);

  const wrappedViewFn = breakpointFilter(mockViewFn);
  const node = document.createElement("div");
  const props = { breakpoints: ["md"] } satisfies { breakpoints: Breakpoint[] } & Record<string, unknown>;

  wrappedViewFn(node, props);

  // Should not call the original view function when media query doesn't match
  expect(mockViewFn).not.toHaveBeenCalled();
});

test("calls view function when breakpoint starts matching", () => {
  const mockViewFn = vi.fn().mockReturnValue({
    destroy: vi.fn(),
  });

  const mockMediaQueryList = new MockMediaQueryList(false);
  mockMatchMedia.mockReturnValue(mockMediaQueryList);

  const wrappedViewFn = breakpointFilter(mockViewFn);
  const node = document.createElement("div");
  const props = { breakpoints: ["md"] } satisfies { breakpoints: Breakpoint[] } & Record<string, unknown>;

  wrappedViewFn(node, props);

  expect(mockViewFn).not.toHaveBeenCalled();

  // Simulate breakpoint matching
  mockMediaQueryList.simulateChange(true);

  expect(mockViewFn).toHaveBeenCalledWith(node, {});
});

test("calls original destroy when breakpoint stops matching", () => {
  const mockDestroy = vi.fn();
  const mockViewFn = vi.fn().mockReturnValue({
    destroy: mockDestroy,
  });

  const mockMediaQueryList = new MockMediaQueryList(true);
  mockMatchMedia.mockReturnValue(mockMediaQueryList);

  const wrappedViewFn = breakpointFilter(mockViewFn);
  const node = document.createElement("div");
  const props = { breakpoints: ["md"] } satisfies { breakpoints: Breakpoint[] } & Record<string, unknown>;

  wrappedViewFn(node, props);

  expect(mockViewFn).toHaveBeenCalled();

  // Simulate breakpoint no longer matching
  mockMediaQueryList.simulateChange(false);

  expect(mockDestroy).toHaveBeenCalled();
});

test("properly handles view function with update method", () => {
  const mockUpdate = vi.fn();
  const mockDestroy = vi.fn();
  const mockViewFn = vi.fn().mockReturnValue({
    destroy: mockDestroy,
    update: mockUpdate,
  });

  const mockMediaQueryList = new MockMediaQueryList(true);
  mockMatchMedia.mockReturnValue(mockMediaQueryList);

  const wrappedViewFn = breakpointFilter(mockViewFn);
  const node = document.createElement("div");
  const props = { breakpoints: ["md"] } satisfies { breakpoints: Breakpoint[] };

  const result = wrappedViewFn(node, props);

  // Test that update method is available and works
  const updateArgs = [{ newProp: "value" }, props] as const;
  result.update(...updateArgs);

  expect(mockUpdate).toHaveBeenCalledWith(...updateArgs);
});

test("handles view function without update method", () => {
  const mockDestroy = vi.fn();
  const mockViewFn = vi.fn().mockReturnValue({
    destroy: mockDestroy,
  });

  const mockMediaQueryList = new MockMediaQueryList(true);
  mockMatchMedia.mockReturnValue(mockMediaQueryList);

  const wrappedViewFn = breakpointFilter(mockViewFn);
  const node = document.createElement("div");
  const props = { breakpoints: ["md"] } satisfies { breakpoints: Breakpoint[] };

  const result = wrappedViewFn(node, props);

  // Should not throw when calling update
  expect(() => result.update({}, {})).not.toThrow();
});

test("properly cleans up event listeners on destroy", () => {
  const mockViewFn = vi.fn().mockReturnValue({
    destroy: vi.fn(),
  });

  const mockMediaQueryList = new MockMediaQueryList(true);
  const removeEventListenerSpy = vi.spyOn(mockMediaQueryList, "removeEventListener");
  mockMatchMedia.mockReturnValue(mockMediaQueryList);

  const wrappedViewFn = breakpointFilter(mockViewFn);
  const node = document.createElement("div");
  const props = { breakpoints: ["md"] } satisfies { breakpoints: Breakpoint[] };

  const result = wrappedViewFn(node, props);

  // Call destroy
  result.destroy();

  // Should remove event listener
  expect(removeEventListenerSpy).toHaveBeenCalledWith("change", expect.any(Function));
});

test("creates correct media query string for single breakpoint", () => {
  const mockViewFn = vi.fn().mockReturnValue({ destroy: vi.fn() });
  const mockMediaQueryList = new MockMediaQueryList(false);
  mockMatchMedia.mockReturnValue(mockMediaQueryList);

  const wrappedViewFn = breakpointFilter(mockViewFn);
  const node = document.createElement("div");

  wrappedViewFn(node, { breakpoints: ["sm"] });

  expect(mockMatchMedia).toHaveBeenCalledWith("(width >= 40rem)");
});

test("creates correct media query string for multiple breakpoints", () => {
  const mockViewFn = vi.fn().mockReturnValue({ destroy: vi.fn() });
  const mockMediaQueryList = new MockMediaQueryList(false);
  mockMatchMedia.mockReturnValue(mockMediaQueryList);

  const wrappedViewFn = breakpointFilter(mockViewFn);
  const node = document.createElement("div");

  wrappedViewFn(node, { breakpoints: ["sm", "md", "xl"] });

  expect(mockMatchMedia).toHaveBeenCalledWith("(width >= 40rem), (width >= 48rem), (width >= 80rem)");
});

test("creates correct media query with comparator override (single)", () => {
  const mockViewFn = vi.fn().mockReturnValue({ destroy: vi.fn() });
  const mockMediaQueryList = new MockMediaQueryList(false);
  mockMatchMedia.mockReturnValue(mockMediaQueryList);

  const wrappedViewFn = breakpointFilter(mockViewFn);
  const node = document.createElement("div");

  const breakpoints = [{ breakpoint: "md", comparator: "<" }] satisfies BreakpointQuery[];
  wrappedViewFn(node, { breakpoints });

  expect(mockMatchMedia).toHaveBeenCalledWith("(width < 48rem)");
});

test("creates correct media query with comparator override (mix)", () => {
  const mockViewFn = vi.fn().mockReturnValue({ destroy: vi.fn() });
  const mockMediaQueryList = new MockMediaQueryList(false);
  mockMatchMedia.mockReturnValue(mockMediaQueryList);

  const wrappedViewFn = breakpointFilter(mockViewFn);
  const node = document.createElement("div");

  const breakpoints = ["sm", { breakpoint: "xl", comparator: "<=" }] satisfies BreakpointQuery[];
  wrappedViewFn(node, { breakpoints });

  expect(mockMatchMedia).toHaveBeenCalledWith("(width >= 40rem), (width <= 80rem)");
});

test("creates correct media query with comparator '='", () => {
  const mockViewFn = vi.fn().mockReturnValue({ destroy: vi.fn() });
  const mockMediaQueryList = new MockMediaQueryList(false);
  mockMatchMedia.mockReturnValue(mockMediaQueryList);

  const wrappedViewFn = breakpointFilter(mockViewFn);
  const node = document.createElement("div");

  const breakpoints = [{ breakpoint: "md", comparator: "=" }] satisfies BreakpointQuery[];
  wrappedViewFn(node, { breakpoints });

  expect(mockMatchMedia).toHaveBeenCalledWith("(width = 48rem)");
});

test("preserves other props when calling wrapped view function", () => {
  const mockViewFn = vi.fn().mockReturnValue({ destroy: vi.fn() });
  const mockMediaQueryList = new MockMediaQueryList(true);
  mockMatchMedia.mockReturnValue(mockMediaQueryList);

  const wrappedViewFn = breakpointFilter(mockViewFn);
  const node = document.createElement("div");
  const props = {
    breakpoints: ["md"],
    customProp: "value",
    anotherProp: 123,
    objectProp: { nested: true },
  } satisfies { breakpoints: Breakpoint[] } & Record<string, unknown>;

  wrappedViewFn(node, props);

  expect(mockViewFn).toHaveBeenCalledWith(node, {
    customProp: "value",
    anotherProp: 123,
    objectProp: { nested: true },
  });
});

describe("breakpointMatches", () => {
  test("returns all breakpoints as false when none match", () => {
    mockMatchMedia.mockReturnValue(new MockMediaQueryList(false));

    const result = breakpointMatches();

    expect(result).toEqual({
      sm: false,
      md: false,
      lg: false,
      xl: false,
      "2xl": false,
    });

    // Should call matchMedia for each breakpoint
    expect(mockMatchMedia).toHaveBeenCalledTimes(5);
    expect(mockMatchMedia).toHaveBeenCalledWith("(width >= 40rem)");
    expect(mockMatchMedia).toHaveBeenCalledWith("(width >= 48rem)");
    expect(mockMatchMedia).toHaveBeenCalledWith("(width >= 64rem)");
    expect(mockMatchMedia).toHaveBeenCalledWith("(width >= 80rem)");
    expect(mockMatchMedia).toHaveBeenCalledWith("(width >= 96rem)");
  });

  test("returns correct match status for each breakpoint", () => {
    // Mock different match results for different breakpoints
    mockMatchMedia.mockImplementation((query: string) => {
      const matches = query.includes("48rem") || query.includes("64rem"); // md and lg match
      return new MockMediaQueryList(matches);
    });

    const result = breakpointMatches();

    expect(result).toEqual({
      sm: false,
      md: true,
      lg: true,
      xl: false,
      "2xl": false,
    });
  });

  test("returns all breakpoints as true when all match", () => {
    mockMatchMedia.mockReturnValue(new MockMediaQueryList(true));

    const result = breakpointMatches();

    expect(result).toEqual({
      sm: true,
      md: true,
      lg: true,
      xl: true,
      "2xl": true,
    });
  });

  test("uses correct media query strings for Tailwind breakpoints", () => {
    mockMatchMedia.mockReturnValue(new MockMediaQueryList(false));

    breakpointMatches();

    // Verify the exact media query strings match Tailwind's breakpoints
    expect(mockMatchMedia).toHaveBeenCalledWith("(width >= 40rem)"); // sm
    expect(mockMatchMedia).toHaveBeenCalledWith("(width >= 48rem)"); // md
    expect(mockMatchMedia).toHaveBeenCalledWith("(width >= 64rem)"); // lg
    expect(mockMatchMedia).toHaveBeenCalledWith("(width >= 80rem)"); // xl
    expect(mockMatchMedia).toHaveBeenCalledWith("(width >= 96rem)"); // 2xl
  });
});
