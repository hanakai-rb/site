# Site

This is the upcoming [Hanakai](https://hanakai.org) website. It’s still a work in progress.

## Organizing development

We track our development entirely using [issues on this repo](https://github.com/hanakai-rb/site/issues). Orgnize your issues according to these main issue labels: [area/backend][backend-label], [area/design][design-label] and [area/content][content-label].

For the site’s initial launch, we’re tracking our work [in this project board][launch-project].

[launch-project]: https://github.com/orgs/hanakai-rb/projects/2/views/1
[backend-label]: https://github.com/hanakai-rb/site/issues?q=state%3Aopen%20label%3Aarea%2Fbackend
[design-label]: https://github.com/hanakai-rb/site/issues?q=state%3Aopen%20label%3Aarea%2Fcontent
[content-label]: https://github.com/hanakai-rb/site/issues?q=state%3Aopen%20label%3Aarea%2Fdesign

## Setup

Make sure you have Ruby and Node.js installed. See [.tool-versions](.tool-versions) for expected versions. Feel free to use your own preferred version manager.

Then, to set up the site:

```shell
$ bin/setup
```

To see common commands for operating the site:

```shell
$ bin/setup help
```

## Working on guides

### Creating an unlisted version

An unlisted guide version is published at its own URL, but the site does not show it in guide lists or version pickers. It is also not used as the latest version. Use this to prepare a new guide version before you announce it.

How you unlist a version depends on how its guides are versioned.

#### Org-versioned guides

Hanami and Rom version all their guides together, in folders like `content/guides/hanami/v3.0/`. To unlist all the guides for a version, add `unlisted: true` to inside that version's `guides.yml`:

```yaml
# content/guides/hanami/v3.0/guides.yml
unlisted: true
guides:
  - slug: getting-started
    # ...
```

#### Self-versioned guides

The Dry guides are versioned on their own, in folders like `content/guides/dry/dry-schema/v1.17/`. To unlist one version of one guide, add a `guide.yml` file to that version's folder:

```yaml
# content/guides/dry/dry-schema/v1.17/guide.yml
unlisted: true
```

If you unlist every version of a guide, that guide does not show in the org's guide list.

#### Unversioned guides

Guides with no version folders (such as `content/guides/dry/getting-started/`) cannot be unlisted.
