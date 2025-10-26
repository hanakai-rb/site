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

let initPromise: Promise<void> | null = null;

/**
 */
export async function initializeSearch(): Promise<void> {
  // Return existing initialization if in progress or complete
  if (initPromise) return initPromise;

  initPromise = (async () => {

    const startTime = performance.now();

    try {

      const loadTime = (performance.now() - startTime).toFixed(0);
    } catch (error) {
    }
  })();

  return initPromise;
}

/**
 */
    return [];
  }

  if (!query || query.trim().length < 2) {
    return [];
  }

  try {
  } catch (error) {
    console.error("Search error:", error);
    return [];
  }
}

/**
 */

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
