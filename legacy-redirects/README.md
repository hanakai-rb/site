# Legacy site redirects

Per-domain Netlify sites that redirect legacy traffic to hanakai.org.

Each subdirectory holds:

- [`_redirects`][https://docs.netlify.com/routing/redirects/] rules for the domain.
- A `netlify.toml` that publishes from the subdirectory and skips the builds unless that
  subdirectory changed.

## Deployment

Each `legacy-directs/` subdirectory has its own Netlify site, configured like so:

1. Connected to this repo, production branch `main`.
2. **Base directory** matching the respective `legacy-redirects/` subdirectory. Netlify uses this to
   find the per-site `netlify.toml`.
3. **Build command** and **publish directory** left empty.
4. Custom domain configured.
