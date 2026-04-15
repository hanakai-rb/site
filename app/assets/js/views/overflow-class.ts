import type { ViewFn } from "@icelab/defo";

type Props = {
  x?: boolean;
  y?: boolean;
  overflowXClass?: string;
  overflowYClass?: string;
};

/**
 * overflowClass
 *
 * Observes the node with ResizeObserver and adds/removes a class name when
 * its content overflows in x or y.
 *
 * @example
 * <div data-defo-overflow-class='{"x": true, "overflowXClass": "is-overflowing"}'>
 *   ...wide content...
 * </div>
 */
export const overflowClassViewFn: ViewFn<Props> = (
  node: HTMLElement,
  { x = false, y = false, overflowXClass = "overflow-x", overflowYClass = "overflow-y" }: Props,
) => {
  if (!x && !y) return;

  const xClasses = overflowXClass.split(" ");
  const yClasses = overflowYClass.split(" ");

  const update = () => {
    if (x) xClasses.forEach((c) => node.classList.toggle(c, node.scrollWidth > node.clientWidth));
    if (y) yClasses.forEach((c) => node.classList.toggle(c, node.scrollHeight > node.clientHeight));
  };

  const resizeObserver = new ResizeObserver(update);
  resizeObserver.observe(node);

  return {
    destroy: () => resizeObserver.disconnect(),
  };
};
