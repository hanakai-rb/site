import type { ViewFn } from '@icelab/defo';
import { initializeSearch, search, groupResults, type SearchResult } from '~/search';

interface StaticSearchElements {
  input: HTMLInputElement;
  results: HTMLElement;
  overlay?: HTMLElement;
}

export const staticSearchViewFn: ViewFn = (element: HTMLElement) => {
  const input = element.querySelector<HTMLInputElement>('[data-static-search-input]');
  const results = element.querySelector<HTMLElement>('[data-static-search-results]');
  const overlay = element.querySelector<HTMLElement>('[data-static-search-overlay]');

  if (!input || !results) {
    console.error('Static search: missing required elements');
    return {
      destroy: () => {},
    };
  }

  const els: StaticSearchElements = { input, results, ...(overlay && { overlay }) };

  let isIndexLoaded = false;

  // Lazy load search index on first focus
  const loadIndex = async () => {
    if (isIndexLoaded) return;

    try {
      input.placeholder = 'Loading search...';
      await initializeSearch();
      isIndexLoaded = true;
      input.placeholder = 'Search docs...';
    } catch (error) {
      console.error('Failed to load search index:', error);
      input.placeholder = 'Search unavailable';
    }
  };

  // Handle input changes
  const handleInput = async () => {
    const query = input.value.trim();

    if (query.length < 2) {
      hideResults(els);
      return;
    }

    if (!isIndexLoaded) {
      await loadIndex();
    }

    const searchResults = search(query, 15);
    displayResults(els, searchResults, query);
  };

  // Handle keyboard shortcuts
  const handleKeydown = (e: KeyboardEvent) => {
    // Cmd+K or Ctrl+K to focus search
    if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
      e.preventDefault();
      input.focus();
    }

    // Escape to close
    if (e.key === 'Escape') {
      hideResults(els);
      input.blur();
    }
  };

  // Event listeners
  input.addEventListener('focus', loadIndex);
  input.addEventListener('input', handleInput);
  document.addEventListener('keydown', handleKeydown);

  // Close on overlay click
  if (overlay) {
    overlay.addEventListener('click', () => hideResults(els));
  }

  // Close on outside click
  const handleOutsideClick = (e: MouseEvent) => {
    if (!element.contains(e.target as Node)) {
      hideResults(els);
    }
  };
  document.addEventListener('click', handleOutsideClick);

  // Cleanup
  return {
    destroy: () => {
      input.removeEventListener('focus', loadIndex);
      input.removeEventListener('input', handleInput);
      document.removeEventListener('keydown', handleKeydown);
      document.removeEventListener('click', handleOutsideClick);
    },
  };
};

/**
 * Display search results grouped by section
 */
function displayResults(els: StaticSearchElements, results: SearchResult[], query: string) {
  if (results.length === 0) {
    els.results.innerHTML = `
      <div class="px-4 py-8 text-center text-gray-500">
        No results found for "${escapeHtml(query)}"
      </div>
    `;
    showResults(els);
    return;
  }

  const grouped = groupResults(results);
  const sections = ['hanami', 'rom', 'dry'] as const;

  const html = sections
    .filter((section) => grouped[section].length > 0)
    .map((section) => renderSection(section, grouped[section]))
    .join('');

  els.results.innerHTML = html;
  showResults(els);
}

/**
 * Render a section group with its results
 */
function renderSection(section: string, results: SearchResult[]): string {
  return `
    <div class="section-group border-b border-gray-200 last:border-0">
      <div class="px-4 py-2 bg-gray-50 text-xs font-semibold uppercase text-gray-600 sticky top-0">
        ${escapeHtml(section)}
      </div>
      ${results.map((result) => renderResult(result)).join('')}
    </div>
  `;
}

/**
 * Render individual search result
 */
function renderResult(result: SearchResult): string {
  const versionBadge = result.isLatest
    ? '<span class="text-xs px-2 py-0.5 bg-green-100 text-green-700 rounded font-medium">Latest</span>'
    : `<span class="text-xs px-2 py-0.5 bg-gray-100 text-gray-600 rounded font-medium">${escapeHtml(result.version)}</span>`;

  return `
    <a
      href="${escapeHtml(result.path)}"
      class="block px-4 py-3 hover:bg-blue-50 border-l-4 border-transparent hover:border-blue-500 transition-colors"
    >
      <div class="flex items-start justify-between gap-3">
        <div class="flex-1 min-w-0">
          <div class="font-medium text-gray-900 flex items-center gap-2 flex-wrap">
            <span class="truncate">${escapeHtml(result.title)}</span>
            ${versionBadge}
          </div>

          <div class="text-sm text-gray-600 mt-1">
            ${escapeHtml(result.section)} › ${escapeHtml(result.subsection)}
          </div>

          ${result.content ? `
            <div class="text-sm text-gray-500 mt-1 line-clamp-2">
              ${escapeHtml(result.content.substring(0, 150))}${result.content.length > 150 ? '...' : ''}
            </div>
          ` : ''}
        </div>
      </div>
    </a>
  `;
}

/**
 * Show results dropdown
 */
function showResults(els: StaticSearchElements) {
  els.results.classList.remove('hidden');
  if (els.overlay) {
    els.overlay.classList.remove('hidden');
  }
}

/**
 * Hide results dropdown
 */
function hideResults(els: StaticSearchElements) {
  els.results.classList.add('hidden');
  if (els.overlay) {
    els.overlay.classList.add('hidden');
  }
}

/**
 * Escape HTML to prevent XSS
 */
function escapeHtml(text: string): string {
  const div = document.createElement('div');
  div.textContent = text;
  return div.innerHTML;
}
