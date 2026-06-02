# Flathub Runtime 50 Update Plan

## Overview

Flathub maintainer [yakushabb](https://github.com/yakushabb) opened [PR #3](https://github.com/flathub/org.roojs.roobuilder/pull/3) to update the Flatpak from GNOME SDK 48 to SDK 50. SDK 48 is EOL.

**PR #3 merged 2026-06-02.** Flathub will rebuild and publish automatically. Nothing else required unless you want to ship upstream metainfo fixes (Part B below).

---

## Step-by-step: what to do (start here)

### Two repos — don't mix them up

| Repo | What it is | Where |
|------|------------|--------|
| **roojs/roobuilder** | Your application source code (Vala, meson, etc.) | This workspace: `/home/alan/gitlive/roobuilder` |
| **flathub/org.roojs.roobuilder** | Flathub's *packaging* repo — a small JSON file that tells Flathub how to build your app | https://github.com/flathub/org.roojs.roobuilder |

Flathub does **not** build from your roobuilder repo directly. It reads `org.roojs.roobuilder.json` on the Flathub repo, which points at your git tag `release-5.0.11`.

**Ignore `~/git/flathub`** — that is an old local build copy (runtime 45), not the official Flathub repo.

---

### Part A — Approve and merge PR #3 (do this first, ~10 minutes)

**What is a PR?** A "pull request" is someone else's proposed change on GitHub. yakushabb prepared the runtime update. You review it; once merged, Flathub automatically rebuilds and publishes the new Flatpak. **You do not need to change any code for this part.**

#### A1. Open the PR in your browser

1. Go to: https://github.com/flathub/org.roojs.roobuilder/pull/3  
2. Log in to GitHub as **roojs** (or whichever account owns the app on Flathub).

#### A2. Skim what changed (optional)

1. Click the **Files changed** tab.  
2. You should see mainly:
   - `org.roojs.roobuilder.json` — runtime `48` → `50`
   - `fix-appdata.patch` — small metainfo tweak at build time
   - removal of unused `shared-modules` stuff  
3. flathubbot should show a green **Test build succeeded** comment on the PR.

#### A3. Approve the PR

1. Click the green **Review changes** button (top right of the Files changed area, or on the Conversation tab).  
2. Select **Approve**.  
3. Add a short comment if you like, e.g. `Looks good, thanks.`  
4. Click **Submit review**.

#### A4. Merge the PR

1. Back on the **Conversation** tab, look for a green **Merge pull request** button.  
2. Click **Merge pull request**, then **Confirm merge**.

**If you don't see a Merge button** — you may only have reviewer access, not write access. That's fine:

1. Leave an approved review (step A3).  
2. Comment: `@yakushabb Approved — please merge when you can.`  
3. yakushabb (Flathub maintainer) will click merge for you.

#### A5. Wait for Flathub to publish (automatic)

After merge, you don't need to do anything:

1. Flathub's bots pick up the change within hours (sometimes same day).  
2. They build a new Flatpak with runtime 50.  
3. Users get it via `flatpak update` or from https://flathub.org/apps/org.roojs.roobuilder  

You can watch the **Conversation** tab on the PR or the repo for flathubbot build messages.

#### A6. Optional — test before it's live for everyone

Only if you want to try the build yakushabb already made:

```bash
flatpak install --user https://dl.flathub.org/build-repo/268639/org.roojs.roobuilder.flatpakref
```

(This is the test build from March 2026; link may expire eventually.)

**That's it for the urgent runtime update.** No changelog, no new tag, no changes in this roobuilder repo required.

---

### Part B — Later: ship your metainfo fixes (optional, when you want)

We already edited `org.roojs.roobuilder.metainfo.xml` in **this repo** (developer URL, vcs-browser link, screenshot whitespace). Those changes are **not** on Flathub until you cut a **new release** and update the Flathub manifest. **Skip Part B until after Part A is done** unless you want everything in one go.

#### B1. Finish the changelog (this repo)

```bash
cd /home/alan/gitlive/roobuilder
```

Edit `debian/changelog` — change the top entry from `UNRELEASED` to `stable` (or run `dch -i` to bump to `5.0.12` and edit the bullet points). Add a line about metainfo / Flathub fixes, e.g.:

```
  * AppStream metadata fixes for Flathub (vcs-browser URL, developer block)
```

#### B2. Bump the version in the app

Edit `src/Application.vala` — update `release_version` (currently `"5.0.11"`) to match changelog, e.g. `"5.0.12"`.

#### B3. Update metainfo release entry

Edit `org.roojs.roobuilder.metainfo.xml` — add a new release at the top of `<releases>`:

```xml
<release version="5.0.12" date="2026-06-02">
  <description>
    <p>AppStream metadata fixes for Flathub.</p>
  </description>
</release>
```

(Use today's date when you actually release.)

#### B4. Update local flatpak manifest (optional but good)

Edit `org.roojs.roobuilder.json` in this repo — change the roobuilder tag to `release-5.0.12` (and runtime to `50` if you want local builds to match Flathub after Part A).

#### B5. Commit, tag, and push (this repo)

```bash
cd /home/alan/gitlive/roobuilder
git add debian/changelog src/Application.vala org.roojs.roobuilder.metainfo.xml org.roojs.roobuilder.json
git commit -m "Release 5.0.12 — AppStream metadata fixes"
git tag release-5.0.12
git push origin master    # or main — whichever branch you use
git push origin release-5.0.12
```

#### B6. Tell Flathub to use the new tag

Either open a new PR on https://github.com/flathub/org.roojs.roobuilder (GitHub web: **Fork** not needed if you have access — use **Add file** / edit online, or clone and push), **or** ask yakushabb in a comment on PR #3 or a new issue:

> Please update the roobuilder module to tag `release-5.0.12` and remove `fix-appdata.patch` — upstream metainfo now has those fixes.

In `org.roojs.roobuilder.json` on the Flathub repo, change:

```json
"tag": "release-5.0.11"
```

to:

```json
"tag": "release-5.0.12",
"commit": "<full git sha of the tag>"
```

…and remove the `fix-appdata.patch` entry from `sources` if the patch is no longer needed.

If you're not comfortable editing the Flathub repo yourself, **steps B1–B5 plus a message to yakushabb is enough** — Flathub maintainers do this routinely.

---

### Quick reference — what needs what

| Goal | Where | New release? | Changelog? |
|------|--------|--------------|------------|
| Fix EOL runtime (SDK 50) | GitHub: merge PR #3 on flathub/org.roojs.roobuilder | No | No |
| Ship metainfo fixes we made | This repo: tag `release-5.0.12`, then update Flathub JSON | Yes | Yes (`debian/changelog` + metainfo `<release>`) |

---

## Context

| Item | Value |
|------|-------|
| Flathub app | [org.roojs.roobuilder](https://flathub.org/apps/details/org.roojs.roobuilder) |
| Flathub repo | https://github.com/flathub/org.roojs.roobuilder |
| Open PR | https://github.com/flathub/org.roojs.roobuilder/pull/3 |
| Current published runtime | GNOME SDK **48** (EOL) |
| Proposed runtime | GNOME SDK **50** |
| App version pinned in manifest | `release-5.0.11` |

## What PR #3 Changes

### `org.roojs.roobuilder.json`

- `runtime-version`: `48` → `50`
- Removes Vala SDK `build-options` (`append-path` / `prepend-ld-library-path`) — not needed on SDK 50
- Simplifies `cleanup` array; adds `/share/vala`
- Adds pinned `commit` hashes for reproducible builds:
  - `roojspacker` tag `release-1.5.2` → commit `9e80138b4a487cf4d7364d8aa055fe78a06edd31`
  - `roobuilder` tag `release-5.0.11` → commit `f1f01d604703aa7f4bf38a6c0735964e36e85667`
- Applies `fix-appdata.patch` during the roobuilder module build

### `fix-appdata.patch` (new)

Patches `org.roojs.roobuilder.metainfo.xml` at build time:

- Removes `<url type="homepage">` from inside `<developer>`
- Replaces screenshot URLs from `roojs.org` with Flathub CDN URLs

The screenshot change was required because the first test build failed with:

```
Error: 'appstream-missing-screenshots' error found in linter repo check.
Details: Catalogue file has no screenshots. Please check if screenshot URLs are reachable
```

The `roojs.org` screenshot URLs were unreachable when the PR was opened (broken TLS cert on the site). **Fixed 2026-06-02** — all four URLs now return HTTP 200.

**Upstream metainfo (2026-06-02):** Applied the non-screenshot parts of `fix-appdata.patch` in this repo (developer URL removal, `vcs-browser` URL, whitespace fix). Screenshot URLs intentionally kept on `roojs.org` — do not adopt Flathub CDN URLs upstream. Flathub can drop `fix-appdata.patch` on a future release after tagging a new roobuilder version.

### Housekeeping

- Removes unused `shared-modules` git submodule (`.gitmodules` deleted)

## Linter Status After PR

| Check | Status |
|-------|--------|
| Test build | Passed |
| Screenshots | Fixed via patch |
| `appstream-missing-vcs-browser-url` | Warning only (non-blocking) |

Recommended upstream fix for the warning:

```xml
<url type="vcs-browser">https://github.com/roojs/roobuilder</url>
```

## Technical details (reference)

| File | Role |
|------|------|
| `org.roojs.roobuilder.json` | Upstream copy of Flatpak manifest (currently runtime 48) |
| `org.roojs.roobuilder.metainfo.xml` | AppStream metadata shipped with the app |
| `org.roojs.roobuilder.desktop` | Desktop entry |

After merging the Flathub PR, consider updating `org.roojs.roobuilder.json` here to match runtime 50 for local Flatpak builds.

## Timeline

| Date | Event |
|------|-------|
| 2026-03-25 | PR opened; first build failed (missing screenshots) |
| 2026-03-25 | Second commit added `fix-appdata.patch`; test build passed |
| 2026-05-19 | yakushabb pinged `@roojs` — runtime EOL, review requested |
| 2026-06-02 | `roojs.org` TLS cert fixed; screenshot URLs reachable again |
| 2026-06-02 | PR #3 merged — runtime 50 update published to Flathub build pipeline |

## References

- [PR #3 conversation](https://github.com/flathub/org.roojs.roobuilder/pull/3)
- [EOL review request comment](https://github.com/flathub/org.roojs.roobuilder/pull/3#issuecomment-4486959298)
- [Successful test build (run 23548830132)](https://github.com/flathub-infra/vorarbeiter/actions/runs/23548830132)
