import { beforeEach, expect, test, describe, vi } from "vitest";
import defo from "@icelab/defo";
import { toggleClassViewFn } from "./toggle-class";

// Render a config to the DOM and initialise defo with our test view function
function render(config: Parameters<typeof toggleClassViewFn>[1]) {
  document.body.innerHTML = `
    <button id="trigger" data-defo-toggle-class='${JSON.stringify(config)}'>
      <span>Trigger</span>
    </button>
    <div id="popover" class="popover hidden">Target</div>
    <div id="popover2" class="popover hidden">Target</div>
  `;
  defo({ views: { toggleClass: toggleClassViewFn } });
}

describe("toggleClassViewFn", () => {
  beforeEach(() => {
    document.body.innerHTML = "";
  });

  test("toggles class on target and trigger on click", () => {
    render({
      targetSelector: "#popover",
      targetToggleClassName: "hidden flex",
      triggerToggleClassName: "active",
    });

    const trigger = document.getElementById("trigger")!;
    const popover = document.getElementById("popover")!;

    // Initial state
    expect(trigger.classList.contains("active")).toBe(false);
    expect(popover.classList.contains("hidden")).toBe(true);
    expect(popover.classList.contains("flex")).toBe(false);

    // Simulate click
    trigger.dispatchEvent(new MouseEvent("click", { bubbles: true }));

    expect(trigger.classList.contains("active")).toBe(true);
    expect(popover.classList.contains("hidden")).toBe(false);
    expect(popover.classList.contains("flex")).toBe(true);

    // Simulate another click (toggle off)
    trigger.dispatchEvent(new MouseEvent("click", { bubbles: true }));

    expect(trigger.classList.contains("active")).toBe(false);
    expect(popover.classList.contains("hidden")).toBe(true);
    expect(popover.classList.contains("flex")).toBe(false);
  });

  test("allows multiple targets", () => {
    render({
      targetSelector: ".popover",
      targetToggleClassName: "hidden flex",
      triggerToggleClassName: "active",
    });

    const trigger = document.getElementById("trigger")!;
    const popover = document.getElementById("popover")!;
    const popover2 = document.getElementById("popover2")!;

    // Initial state
    expect(trigger.classList.contains("active")).toBe(false);
    expect(popover.classList.contains("hidden")).toBe(true);
    expect(popover.classList.contains("flex")).toBe(false);
    expect(popover2.classList.contains("hidden")).toBe(true);
    expect(popover2.classList.contains("flex")).toBe(false);

    // Simulate click
    trigger.dispatchEvent(new MouseEvent("click", { bubbles: true }));

    expect(trigger.classList.contains("active")).toBe(true);
    expect(popover.classList.contains("hidden")).toBe(false);
    expect(popover.classList.contains("flex")).toBe(true);
    expect(popover2.classList.contains("hidden")).toBe(false);
    expect(popover2.classList.contains("flex")).toBe(true);

    // Simulate another click (toggle off)
    trigger.dispatchEvent(new MouseEvent("click", { bubbles: true }));

    expect(trigger.classList.contains("active")).toBe(false);
    expect(popover.classList.contains("hidden")).toBe(true);
    expect(popover.classList.contains("flex")).toBe(false);
    expect(popover2.classList.contains("hidden")).toBe(true);
    expect(popover2.classList.contains("flex")).toBe(false);
  });

  test("toggles only target class if triggerToggleClassName is not set", () => {
    render({
      targetSelector: "#popover",
      targetToggleClassName: "shown",
    });

    const trigger = document.getElementById("trigger")!;
    const popover = document.getElementById("popover")!;

    expect(popover.classList.contains("shown")).toBe(false);

    trigger.dispatchEvent(new MouseEvent("click", { bubbles: true }));

    expect(popover.classList.contains("shown")).toBe(true);

    trigger.dispatchEvent(new MouseEvent("click", { bubbles: true }));

    expect(popover.classList.contains("shown")).toBe(false);
  });

  test("prevents default event if preventDefault is true", () => {
    render({
      targetSelector: "#popover",
      targetToggleClassName: "shown",
      preventDefault: true,
    });

    const trigger = document.getElementById("trigger")!;
    const event = new MouseEvent("click", { bubbles: true, cancelable: true });
    const preventDefaultSpy = vi.spyOn(event, "preventDefault");

    trigger.dispatchEvent(event);

    expect(preventDefaultSpy).toHaveBeenCalled();
  });

  test("supports custom eventName", () => {
    render({
      targetSelector: "#popover",
      targetToggleClassName: "shown",
      eventName: "mouseenter",
      preventDefault: false,
    });

    const trigger = document.getElementById("trigger")!;
    const popover = document.getElementById("popover")!;

    expect(popover.classList.contains("shown")).toBe(false);

    trigger.dispatchEvent(new MouseEvent("mouseenter", { bubbles: true }));

    expect(popover.classList.contains("shown")).toBe(true);
  });

  test("clickAway toggles off when clicking outside", () => {
    render({
      targetSelector: "#popover",
      targetToggleClassName: "shown",
      triggerToggleClassName: "active",
      clickAway: true,
    });

    const trigger = document.getElementById("trigger")!;
    const popover = document.getElementById("popover")!;

    // Activate
    trigger.dispatchEvent(new MouseEvent("click", { bubbles: true }));

    expect(trigger.classList.contains("active")).toBe(true);
    expect(popover.classList.contains("shown")).toBe(true);

    // Click inside popover (should not deactivate)
    popover.dispatchEvent(new MouseEvent("click", { bubbles: true }));
    expect(trigger.classList.contains("active")).toBe(true);
    expect(popover.classList.contains("shown")).toBe(true);

    // Click outside (should deactivate)
    const outside = document.createElement("div");
    document.body.appendChild(outside);
    outside.dispatchEvent(new MouseEvent("click", { bubbles: true }));

    expect(trigger.classList.contains("active")).toBe(false);
    expect(popover.classList.contains("shown")).toBe(false);
  });

  test("does nothing if targetSelector does not match any elements", () => {
    render({
      targetSelector: "#does-not-exist",
      targetToggleClassName: "shown",
    });

    const trigger = document.getElementById("trigger")!;
    // Should not throw
    expect(() => {
      trigger.dispatchEvent(new MouseEvent("click", { bubbles: true }));
    }).not.toThrow();

    expect(trigger.classList.contains("active")).toBe(false);
  });
});
