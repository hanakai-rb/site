import type { ViewFn } from "@icelab/defo";

/**
 * replaceWithTemplate
 *
 * Replaces the element's content with a clone of its child <template>'s first
 * element. Useful for progressive enhancement: render a simple, semantic
 * fallback in the source HTML and swap in a richer version once JS runs.
 *
 * NOTE: the body of this function is mirrored as an inline <script> at the end
 * of <body> in app/templates/layouts/app.html.erb, which runs synchronously
 * before first paint to avoid a FOUC. Keep the two in sync. The code below is
 * deliberately written so it can be copy-pasted between TS and inline JS
 * unchanged (e.g. an `instanceof` runtime guard rather than a TS-only generic
 * or type predicate).
 *
 * @example
 * <span data-defo-replace-with-template>
 *   Hanami<template><span class="inline-flex">…kerned spans…</span></template>
 * </span>
 */
export const replaceWithTemplateViewFn: ViewFn = (node) => {
  const template = Array.from(node.children).find((c) => c instanceof HTMLTemplateElement);
  if (!(template instanceof HTMLTemplateElement)) return;
  const replacement = template.content.firstElementChild;
  if (!replacement) return;
  node.replaceChildren(replacement.cloneNode(true));
};
