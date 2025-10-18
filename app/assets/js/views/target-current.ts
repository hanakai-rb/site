import type { ViewFn } from "@icelab/defo";

type Props = {
  activeClassNames: string[];
};

export const targetCurrentViewFn: ViewFn<Props> = (containerNode: HTMLElement, { activeClassNames }: Props) => {
  let activeHash: string | undefined = undefined;

  const onHashChange = () => {
    if (activeHash) {
      deactivate(activeHash);
    }
    if (window.location.hash !== "") {
      activate(window.location.hash);
    }
  };

  const deactivate = (hash: string) => {
    const el = containerNode.querySelector(`a[href="${hash}"]`);
    if (el) {
      el.classList.remove(...activeClassNames);
    }
  };

  const activate = (hash: string) => {
    const el = containerNode.querySelector(`a[href="${hash}"]`);
    if (el) {
      activeHash = hash;
      el.classList.add(...activeClassNames);
    }
  };

  onHashChange();

  window.addEventListener("hashchange", onHashChange);

  return {
    destroy: () => {
      window.removeEventListener("hashchange", onHashChange);
    },
  };
};
