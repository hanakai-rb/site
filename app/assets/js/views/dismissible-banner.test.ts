import { beforeEach, expect, test, describe } from "vitest";
import defo from "@icelab/defo";
import { dismissibleBannerViewFn } from "./dismissible-banner";

function render(config: Parameters<typeof dismissibleBannerViewFn>[1]) {
  document.body.innerHTML = `
    <div id="banner" data-defo-dismissible-banner='${JSON.stringify(config)}'>
      <a href="/post">Announcement</a>
      <button type="button">Dismiss</button>
      <button type="button" data-custom-dismiss>Custom dismiss</button>
    </div>
  `;
  defo({ views: { dismissibleBanner: dismissibleBannerViewFn } });
}

describe("dismissibleBannerViewFn", () => {
  beforeEach(() => {
    document.body.innerHTML = "";
    window.localStorage.clear();
  });

  test("hides the banner and stores the dismissal on click", () => {
    render({ id: "hanakai" });

    const banner = document.getElementById("banner")!;
    const button = banner.querySelector("button")!;

    expect(banner.classList.contains("hidden")).toBe(false);
    expect(window.localStorage.getItem("hk-banner-dismissed:hanakai")).toBe(null);

    button.dispatchEvent(new MouseEvent("click", { bubbles: true }));

    expect(banner.classList.contains("hidden")).toBe(true);
    expect(window.localStorage.getItem("hk-banner-dismissed:hanakai")).toBe("true");
  });

  test("scopes the storage key to the provided id", () => {
    render({ id: "other-banner" });

    const button = document.querySelector("#banner button")!;
    button.dispatchEvent(new MouseEvent("click", { bubbles: true }));

    expect(window.localStorage.getItem("hk-banner-dismissed:other-banner")).toBe("true");
    expect(window.localStorage.getItem("hk-banner-dismissed:hanakai")).toBe(null);
  });

  test("uses a custom dismissSelector when provided", () => {
    render({ id: "hanakai", dismissSelector: "[data-custom-dismiss]" });

    const banner = document.getElementById("banner")!;
    const defaultButton = banner.querySelector("button")!;
    const customButton = banner.querySelector("[data-custom-dismiss]")!;

    defaultButton.dispatchEvent(new MouseEvent("click", { bubbles: true }));
    expect(banner.classList.contains("hidden")).toBe(false);
    expect(window.localStorage.getItem("hk-banner-dismissed:hanakai")).toBe(null);

    customButton.dispatchEvent(new MouseEvent("click", { bubbles: true }));
    expect(banner.classList.contains("hidden")).toBe(true);
    expect(window.localStorage.getItem("hk-banner-dismissed:hanakai")).toBe("true");
  });

  test("does nothing if no matching dismiss button exists", () => {
    document.body.innerHTML = `
      <div id="banner" data-defo-dismissible-banner='${JSON.stringify({ id: "hanakai" })}'>
        <a href="/post">Announcement</a>
      </div>
    `;

    expect(() => {
      defo({ views: { dismissibleBanner: dismissibleBannerViewFn } });
    }).not.toThrow();

    const banner = document.getElementById("banner")!;
    expect(banner.classList.contains("hidden")).toBe(false);
  });
});
