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
  excerpt?: string;
}

export interface GroupedResults {
  hanami: SearchResult[];
  rom: SearchResult[];
  dry: SearchResult[];
  blog: SearchResult[];
  community: SearchResult[];
}

let pagefind: any | null = null;
let initPromise: Promise<void> | null = null;

/**
 * Initialize Pagefind search (lazy loaded on first use)
 */
export async function initializeSearch(): Promise<void> {
  // Return existing initialization if in progress or complete
  if (initPromise) return initPromise;

  initPromise = (async () => {
    if (pagefind) return;

    console.log("Loading Pagefind search...");
    const startTime = performance.now();

    try {
      // @ts-ignore - Pagefind is dynamically loaded
      pagefind = await import("/pagefind/pagefind.js");
      await pagefind.init();

      const loadTime = (performance.now() - startTime).toFixed(0);
      console.log(`✓ Pagefind loaded in ${loadTime}ms`);
    } catch (error) {
      console.warn("Pagefind not available (this is normal in development mode):", error);
      // In development mode, Pagefind won't be available since pages aren't pre-rendered
      // Search will work in production after running bin/static-build
      return;
    }
  })();

  return initPromise;
}

/**
 * Search documents using Pagefind
 */
export async function search(query: string, maxResults: number = 10): Promise<SearchResult[]> {
  if (!pagefind) {
    console.warn("Pagefind not initialized");
    return [];
  }

  if (!query || query.trim().length < 2) {
    return [];
  }

  try {
    const searchResults = await pagefind.search(query);

    // Load the full data for each result
    const results: SearchResult[] = await Promise.all(
      searchResults.results.slice(0, maxResults).map(async (result: any) => {
        const data = await result.data();

        // Extract metadata from Pagefind's result
        // Pagefind provides url, excerpt, and meta fields
        const url = data.url;
        const excerpt = data.excerpt;

        // Parse section from URL or meta
        const section = extractSection(url);

        return {
          id: result.id || url,
          title: data.meta?.title || extractTitleFromUrl(url),
          section,
          subsection: data.meta?.subsection,
          version: data.meta?.version,
          path: url,
          content: excerpt || "",
          excerpt,
          headings: data.meta?.headings || [],
          isLatest: data.meta?.isLatest === "true",
          date: data.meta?.date,
          score: result.score || 0,
        };
      }),
    );

    return sortResults(results);
  } catch (error) {
    console.error("Search error:", error);
    return [];
  }
}

/**
 * Extract section from URL path
 */
function extractSection(url: string): string {
  if (url.includes("/blog/")) return "blog";
  if (url.includes("/docs/hanami")) return "hanami";
  if (url.includes("/guides/hanami")) return "hanami";
  if (url.includes("/docs/dry") || url.includes("/guides/dry")) return "dry";
  if (url.includes("/docs/rom") || url.includes("/guides/rom")) return "rom";
  if (url.includes("/community") || url.includes("/conduct")) return "community";
  return "hanami"; // default
}

/**
 * Extract title from URL as fallback
 */
function extractTitleFromUrl(url: string): string {
  const parts = url.split("/").filter((p) => p);
  const lastPart = parts[parts.length - 1] || "Untitled";
  return lastPart
    .split("-")
    .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
    .join(" ");
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
