const loadedScripts = new Map();
/**
 * Load an external script
 * @param src
 * @returns Promise
 */
export function loadScript(src: string) {
  if (loadedScripts.has(src)) {
    return loadedScripts.get(src);
  }

  const promise = new Promise((resolve, reject) => {
    const script = document.createElement("script");
    script.src = src;
    script.onload = () => resolve(script);
    script.onerror = () => reject(new Error(`Failed to load script: ${src}`));
    document.head.appendChild(script);
  });

  loadedScripts.set(src, promise);
  return promise;
}

const loadedStyles = new Map();

/**
 * Load an external CSS file
 * @param href
 * @returns Promise
 */
export function loadCSS(href: string) {
  if (loadedStyles.has(href)) {
    return loadedStyles.get(href);
  }

  const promise = new Promise((resolve, reject) => {
    const link = document.createElement("link");
    link.rel = "stylesheet";
    link.href = href;
    link.onload = () => resolve(link);
    link.onerror = () => reject(new Error(`Failed to load CSS: ${href}`));
    document.head.appendChild(link);
  });

  loadedStyles.set(href, promise);
  return promise;
}
