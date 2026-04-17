import { beforeEach, expect, test, describe } from "vitest";
import defo from "@icelab/defo";
import { replaceWithTemplateViewFn } from "./replace-with-template";

function render(html: string) {
  document.body.innerHTML = html;
  defo({ views: { replaceWithTemplate: replaceWithTemplateViewFn } });
}

describe("replaceWithTemplateViewFn", () => {
  beforeEach(() => {
    document.body.innerHTML = "";
  });

  test("replaces content with the template's first element", () => {
    render(`
      <span id="name" data-defo-replace-with-template>
        Hanami<template><span class="kerned"><span>H</span><span>i</span></span></template>
      </span>
    `);

    const node = document.getElementById("name")!;
    expect(node.querySelector(".kerned")).not.toBeNull();
    expect(node.querySelector("template")).toBeNull();
    expect(node.textContent?.trim()).toBe("Hi");
  });

  test("does nothing when no template is present", () => {
    render(`<span id="name" data-defo-replace-with-template>Hanami</span>`);

    const node = document.getElementById("name")!;
    expect(node.textContent).toBe("Hanami");
  });

  test("only replaces from a direct-child template", () => {
    render(`
      <span id="outer" data-defo-replace-with-template>
        Outer<template><span class="outer-replacement">replaced</span></template>
        <span><template>nested</template></span>
      </span>
    `);

    const node = document.getElementById("outer")!;
    expect(node.querySelector(".outer-replacement")).not.toBeNull();
    expect(node.textContent?.trim()).toBe("replaced");
  });
});
