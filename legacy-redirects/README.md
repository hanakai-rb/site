# Legacy site redirects

Per-domain Netlify sites that redirect legacy traffic to hanakai.org.

Each subdirectory holds:

- [`_redirects`][https://docs.netlify.com/routing/redirects/] rules for the domain.
- A `netlify.toml` that publishes from the subdirectory and skips the builds unless that
  subdirectory changed.

## Deployment

Each `legacy-directs/` subdirectory has its own Netlify site, configured like so:

- Connected to this repo, production branch `main`.
- **Base directory** matching the respective `legacy-redirects/` subdirectory.
- **Build command** and **Publish directory** left blank.
- **Build & deploy > Branches and deploy contexts > Preview builds** set to "None".
