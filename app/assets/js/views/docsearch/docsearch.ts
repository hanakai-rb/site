import "@docsearch/css";
import "./docsearch.css";
import docsearch from "@docsearch/js";
import type { ViewFn } from "@icelab/defo";

type Props = { appId: string; apiKey: string; indexName: string };

export const docsearchViewFn: ViewFn<Props> = (container: HTMLElement, { appId, apiKey, indexName }: Props) => {
  docsearch({
    container,
    appId,
    apiKey,
    indexName,
    searchParameters: {
      facetFilters: ["version:latest"],
    },
  });

  return {
    destroy: () => {},
  };
};
