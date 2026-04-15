import { beforeEach, expect, test, describe } from "vitest";
import defo from "@icelab/defo";
import { overflowClassViewFn } from "./overflow-class";

const callbacks = new Set<[ResizeObserverCallback, ResizeObserver]>();
class MockResizeObserver {
  constructor(callback: ResizeObserverCallback) {
    callbacks.add([callback, this as unknown as ResizeObserver]);
  }
  observe = () => {};
  unobserve = () => {};
  disconnect = () => {
    callbacks.clear();
  };
}

function render(config: Parameters<typeof overflowClassViewFn>[1]) {
  document.body.innerHTML = `<div data-defo-overflow-class='${JSON.stringify(config)}'></div>`;
  defo({ views: { overflowClass: overflowClassViewFn } });
  return document.querySelector<HTMLElement>("[data-defo-overflow-class]")!;
}

function triggerResize(
  node: HTMLElement,
  { scrollWidth = 0, clientWidth = 0, scrollHeight = 0, clientHeight = 0 } = {},
) {
  Object.defineProperty(node, "scrollWidth", { value: scrollWidth, configurable: true });
  Object.defineProperty(node, "clientWidth", { value: clientWidth, configurable: true });
  Object.defineProperty(node, "scrollHeight", { value: scrollHeight, configurable: true });
  Object.defineProperty(node, "clientHeight", { value: clientHeight, configurable: true });
  callbacks.forEach(([cb, observer]) => cb([], observer));
}

beforeEach(() => {
  document.body.innerHTML = "";
  callbacks.clear();
  globalThis.ResizeObserver = MockResizeObserver as unknown as typeof ResizeObserver;
});

describe("overflowClassViewFn", () => {
  test("adds x class when scrollWidth exceeds clientWidth", () => {
    const node = render({ x: true, overflowXClass: "is-overflowing-x" });

    triggerResize(node, { scrollWidth: 500, clientWidth: 300 });
    expect(node.classList.contains("is-overflowing-x")).toBe(true);
  });

  test("removes x class when no longer overflowing", () => {
    const node = render({ x: true, overflowXClass: "is-overflowing-x" });

    triggerResize(node, { scrollWidth: 500, clientWidth: 300 });
    expect(node.classList.contains("is-overflowing-x")).toBe(true);

    triggerResize(node, { scrollWidth: 300, clientWidth: 300 });
    expect(node.classList.contains("is-overflowing-x")).toBe(false);
  });

  test("adds y class when scrollHeight exceeds clientHeight", () => {
    const node = render({ y: true, overflowYClass: "is-overflowing-y" });

    triggerResize(node, { scrollHeight: 800, clientHeight: 400 });
    expect(node.classList.contains("is-overflowing-y")).toBe(true);
  });

  test("handles x and y simultaneously", () => {
    const node = render({ x: true, y: true, overflowXClass: "ox", overflowYClass: "oy" });

    triggerResize(node, { scrollWidth: 500, clientWidth: 300, scrollHeight: 800, clientHeight: 400 });
    expect(node.classList.contains("ox")).toBe(true);
    expect(node.classList.contains("oy")).toBe(true);

    triggerResize(node, { scrollWidth: 300, clientWidth: 300, scrollHeight: 400, clientHeight: 400 });
    expect(node.classList.contains("ox")).toBe(false);
    expect(node.classList.contains("oy")).toBe(false);
  });

  test("does nothing when neither x nor y is enabled", () => {
    const node = render({});
    triggerResize(node, { scrollWidth: 500, clientWidth: 300 });
    expect(node.className).toBe("");
  });
});
