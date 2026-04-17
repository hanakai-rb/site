import type { ViewFn } from "@icelab/defo";

/**
 * replaceWithTemplate
 *
 * Replaces the element's content with a clone of its child <template>'s first
 * element. Useful for progressive enhancement: render a simple, semantic
 * fallback in the source HTML and swap in a richer version once JS runs.
 *
 * @example
 * <span data-defo-replace-with-template>
 *   Hanami<template><span class="inline-flex">…kerned spans…</span></template>
 * </span>
 */
export const replaceWithTemplateViewFn: ViewFn = (node: HTMLElement) => {
  const template = Array.from(node.children).find(
    (child): child is HTMLTemplateElement => child instanceof HTMLTemplateElement,
  );
  const replacement = template?.content.firstElementChild;
  if (!replacement) return;

  node.replaceChildren(replacement.cloneNode(true));
};
