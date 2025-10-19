import lunr from "lunr";

export interface SearchDocument {
  id: string;
  title: string;
  section: string;
  subsection?: string;
  version?: string;
  versionWeight?: number;
  path: string;
  content: string;
  headings: string[];
  isLatest?: boolean;
  date?: string;
}

export interface SearchResult extends SearchDocument {
  score: number;
}

export interface GroupedResults {
  hanami: SearchResult[];
  rom: SearchResult[];
  dry: SearchResult[];
  blog: SearchResult[];
  community: SearchResult[];
}

let index: lunr.Index | null = null;
let documents: SearchDocument[] | null = null;
let initPromise: Promise<void> | null = null;

/**
 * Initialize search index (lazy loaded on first use)
 * Loads pre-serialized Lunr index and documents from server
 */
export async function initializeSearch(checksum: string): Promise<void> {
  // Return existing initialization if in progress or complete
  if (initPromise) return initPromise;

  initPromise = (async () => {
    if (index && documents) return;

    console.log("Loading search index...");
    const startTime = performance.now();

    try {
      const [indexData, docsData] = await Promise.all([
        fetch(`/lunr-index.${checksum}.json`).then((r) => r.json()),
        fetch(`/search-documents.${checksum}.json`).then((r) => r.json()),
      ]);

      // Load pre-built index (instant!)
      index = lunr.Index.load(indexData);
      documents = docsData;

      const loadTime = (performance.now() - startTime).toFixed(0);
      console.log(`✓ Search index loaded in ${loadTime}ms (v${checksum})`);
    } catch (error) {
      console.error("Failed to load search index:", error);
      throw error;
    }
  })();

  return initPromise;
}

/**
 * Search documents with version de-duplication and smart sorting
 */
export function search(query: string, maxResults: number = 10): SearchResult[] {
  if (!index || !documents) {
    console.warn("Search index not initialized");
    return [];
  }

  if (!query || query.trim().length < 2) {
    return [];
  }

  try {
    const rawResults = index.search(query);

    // Map to full documents with scores
    let results: SearchResult[] = rawResults.map((result) => {
      const doc = documents!.find((d) => d.id === result.ref);
      if (!doc) throw new Error(`Document not found: ${result.ref}`);

      return {
        ...doc,
        score: result.score,
      };
    });

    // Check if user is searching for specific version
    const hasVersionQuery = /v?\d+\.\d+/.test(query);

    // De-duplicate versions: keep only latest unless user searches for version
    if (!hasVersionQuery) {
      results = deduplicateVersions(results);
    }

    // Sort results intelligently
    results = sortResults(results);

    return results.slice(0, maxResults);
  } catch (error) {
    console.error("Search error:", error);
    return [];
  }
}

/**
 * De-duplicate results by keeping only latest version of each doc
 */
function deduplicateVersions(results: SearchResult[]): SearchResult[] {
  const seen = new Map<string, SearchResult>();

  for (const result of results) {
    const key = `${result.section}/${result.subsection}/${result.title}`;
    const existing = seen.get(key);

    // Keep this result if:
    // - We haven't seen this doc before, OR
    // - This is the latest version
    if (!existing || result.isLatest) {
      seen.set(key, result);
    }
  }

  return Array.from(seen.values());
}

/**
 * Smart sort: Getting Started first, then latest versions, then by score
 */
function sortResults(results: SearchResult[]): SearchResult[] {
  return results.sort((a, b) => {
    // "Getting started" pages always first in each section
    const aIsGettingStarted = /getting.?started/i.test(a.title);
    const bIsGettingStarted = /getting.?started/i.test(b.title);

    if (aIsGettingStarted !== bIsGettingStarted) {
      return aIsGettingStarted ? -1 : 1;
    }

    // Latest versions before older versions
    if (a.isLatest !== b.isLatest) {
      return a.isLatest ? -1 : 1;
    }

    // Finally sort by relevance score
    return b.score - a.score;
  });
}

/**
 * Group search results by section (hanami, rom, dry, blog, community)
 */
export function groupResults(results: SearchResult[]): GroupedResults {
  return results.reduce(
    (groups, result) => {
      const section = result.section as keyof GroupedResults;
      if (groups[section]) {
        groups[section].push(result);
      }
      return groups;
    },
    { hanami: [], rom: [], dry: [], blog: [], community: [] } as GroupedResults,
  );
}

/**
 * Get all unique sections from results
 */
export function getSections(results: SearchResult[]): string[] {
  const sections = new Set(results.map((r) => r.section));
  return Array.from(sections).sort();
}
