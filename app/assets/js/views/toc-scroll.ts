import type { ViewFn } from "@icelab/defo";

import { debounce } from "lodash-es";

type Props = {
  anchorContainerSelector?: string;
  indicatorSelector?: string;
  linkSelector?: string;
};

export const tocScrollViewFn: ViewFn<Props> = (
  linkContainerNode: HTMLElement,
  { anchorContainerSelector, indicatorSelector = ".toc-indicator", linkSelector = "a[href^='#']" }: Props,
) => {
  const { anchors, anchorToLinkMap, indicator, links } = findElements({
    anchorContainerSelector,
    indicatorSelector,
    linkContainerNode,
    linkSelector,
  });

  const firstAnchor = anchors[0];

  // Failed to find anything, bail out
  if (!indicator || !firstAnchor || links.length == 0) {
    return {
      destroy: () => {},
    };
  }

  // Determine the initial position of the indicator (based on the position of the first link
  // element)
  const [firstLink] = anchorToLinkMap.get(firstAnchor)!;
  let indicatorPosition = {
    x: 0,
    y: firstLink?.offsetTop ?? 0,
    initialY: firstLink?.offsetTop ?? 0,
    scale: 0,
  };
  console.log({ indicatorPosition });

  const activeClasses = ["font-bold", "b-primary"];
  const xOffset = 11;
  const xOffsetDepth = 0;

  const onChangeAnchor = (activeAnchor: HTMLElement | undefined) => {
    requestAnimationFrame(() => {
      // Remove active class from all links
      links.forEach((node) => activeClasses.forEach((activeClass) => node.classList.remove(activeClass)));

      // Find the active link tuple
      const activeLinkTuple = activeAnchor ? anchorToLinkMap.get(activeAnchor) : undefined;
      if (activeLinkTuple) {
        const [activeLinkNode, depth] = activeLinkTuple;
        // Add the active class
        activeClasses.forEach((activeClass) => activeLinkNode.classList.add(activeClass));
        // Calculate the position of the indicator
        indicatorPosition = {
          ...indicatorPosition,
          x: xOffset + depth * xOffsetDepth,
          y: activeLinkNode.offsetTop + activeLinkNode.offsetHeight / 2 - 9,
          scale: 1,
        };
      } else {
        // If no match, set the x offset to 0 to hide it
        indicatorPosition.scale = 0;
        indicatorPosition.x = 0;
      }
      // Calculate the rotation between the initial position and current one
      const circumference = 2 * Math.PI * indicator.offsetWidth;
      const distance = Math.abs(indicatorPosition.initialY - indicatorPosition.y);
      const rotationInDegrees = (distance / circumference) * 360;
      // Apply the transform
      indicator.style.transform = `translate(${indicatorPosition.x}px, ${indicatorPosition.y}px) rotate(${rotationInDegrees}deg) scale(${indicatorPosition.scale})`;
      indicator.style.scale = indicatorPosition.scale.toString();
    });
  };

  const onScroll = debounce(
    createOnScrollFn({
      anchors,
      onChangeAnchor,
    }),
    20,
    { maxWait: 150 },
  );

  window.addEventListener("scroll", onScroll);

  return {
    destroy: () => {
      window.removeEventListener("scroll", onScroll);
      links.forEach((node) => activeClasses.forEach((activeClass) => node.classList.remove(activeClass)));
    },
  };
};

/**
 * Find all the elements we need:
 */
export function findElements({
  anchorContainerSelector,
  indicatorSelector,
  linkContainerNode,
  linkSelector,
}: {
  anchorContainerSelector: string | undefined;
  indicatorSelector: string | undefined;
  linkContainerNode: HTMLElement;
  linkSelector: string;
}) {
  // Resolve the links
  const links = Array.from(linkContainerNode.querySelectorAll<HTMLAnchorElement>(linkSelector));
  // Resolve the indicator
  const indicator = indicatorSelector
    ? (document.querySelector<HTMLElement>(indicatorSelector) ?? undefined)
    : undefined;

  // Resolve the container
  let anchorContainer: ParentNode = document;
  if (anchorContainerSelector) {
    const foundAnchorContainer = document.querySelector(anchorContainerSelector);
    if (foundAnchorContainer) {
      anchorContainer = foundAnchorContainer;
    } else {
      throw new Error("Anchor container not found in document");
    }
  }

  // Create a Map of the anchors to the [linkNode, linkDepth]
  const anchorToLinkMap = new Map<HTMLElement, [HTMLAnchorElement, number]>();

  // Iterate over the links and resolve their anchors.
  links.forEach((link) => {
    const href = link.getAttribute("href");
    if (!href || !href.startsWith("#")) return;
    const id = href.slice(1);
    // Try to find by ID or by name
    const anchor =
      anchorContainer.querySelector<HTMLElement>(`#${CSS.escape(id)}`) ||
      anchorContainer.querySelector<HTMLElement>(`[name="${CSS.escape(id)}"]`);
    if (anchor) {
      const depth = parseInt(link.dataset.depth || "0", 10);
      anchorToLinkMap.set(anchor, [link, depth]);
    } else {
      throw new Error(`Anchor missing for link with href: ${href}`);
    }
  });

  // Extract the anchors
  const anchors = Array.from(anchorToLinkMap.keys());

  return {
    anchors,
    anchorToLinkMap,
    indicator,
    links,
  };
}

/**
 * findClosestIndex
 * Find the value in the passed array closest to the `target`.
 * @example
 * const values = [1,2,10]
 * findClosestIndex(values, 9)
 * // -> 2
 */
export function findClosestIndex(arr: number[], target: number) {
  return arr.reduce((closestIndex, curr, i) => {
    const closestIndexValue = arr[closestIndex] ?? 0;
    if (Math.abs(curr - target) < Math.abs(closestIndexValue - target)) {
      return i;
    } else {
      return closestIndex;
    }
  }, 0);
}

// How much of the window to offset the scroll-comparison value by
const WINDOW_THRESHOLD_PERCENTAGE = 0.2;

/**
 * Create the onScroll function
 */
function createOnScrollFn({
  anchors,
  onChangeAnchor,
}: {
  anchors: HTMLElement[];
  onChangeAnchor: (activeAnchor: HTMLElement | undefined) => void;
}) {
  return async () => {
    const viewportMarginThreshold = window.innerHeight * WINDOW_THRESHOLD_PERCENTAGE;
    const yPositions: number[] = [];

    // Create an array of Promises and their resolver functions that matches the length of the
    // `anchors` array.
    const resolverFns: ((value: void | PromiseLike<void>) => void)[] = [];
    const promises = anchors.map(
      () =>
        new Promise<void>((resolve) => {
          resolverFns.push(resolve);
        }),
    );

    // This abuses IntersectionObserver to get the positions of each anchor element without causing
    // reflows (which would occur when using `getBoundingClientRect` directly).
    const observer = new IntersectionObserver((entries) => {
      for (const entry of entries) {
        const { target, boundingClientRect } = entry;
        const index = anchors.indexOf(target as HTMLElement);

        const { y } = boundingClientRect;
        yPositions[index] = y;

        // Find the corresponding resolvedFn and call it.
        const resolverFn = resolverFns[index];
        if (resolverFn) {
          resolverFn();
        } else {
          throw new Error("Mismatch between expect entries and resolvers");
        }
      }

      // Disconnect the observer immediately after the entry resolves
      observer.disconnect();
    });

    // Trigger observer for each anchor
    anchors.forEach((anchor) => observer.observe(anchor));

    // Wait for every item to be measured.
    await Promise.all(promises);

    // Add the window scrollY offset to the start of the yPosition array so we use it as an anchor
    // to ensure we don’t always select the first item.
    yPositions.unshift(window.scrollY * -1);

    // Find the closest matching position (accounting for the fake value from the scroll position)
    const closestIndex = findClosestIndex(yPositions, viewportMarginThreshold) - 1;
    onChangeAnchor(anchors[closestIndex]);
  };
}
