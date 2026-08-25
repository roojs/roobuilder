# VBP round-trip — Roo / JavaScript (Pman)

**Last run:** 2026-08-25. Manifest: `tests/vbp-roundtrip-js.manifest`. Artifacts: `build/vbp-roundtrip-js/`.

Pipeline:

```
Start (.original.bjs)  →  Writer (.vbp)  →  Parser  →  End (.roundtrip.bjs)
```

Disk BJS is often v1 (`items`) → in-memory v3 → VBP → BJS. Vala/Gtk: [`vbp-roundtrip.md`](vbp-roundtrip.md).  
**Generated-code status (what matters):** [`vbp-roundtrip-generated.md`](vbp-roundtrip-generated.md).

| Check | Result |
|--|--|
| Parse `FAIL` | **22** — unclosed opaque brace / unmatched `}` `]` |
| Content `GEN_DIFF` | **208** — quoted object literals, `_strings` / i18n, dropped array RAW |
| Cache fix | Helps where parse succeeds (no more empty props/listeners map) |

## Opaque function bodies

`{` first non-ws on a line → indent-opaque until `}` at the same indent (optional `},` / `;`). Writer emits body indented past the braces. Parser recovers header/body via `CodeParts` (legacy BJS) or token `{}` groups.

## How to re-run

```
ninja -C build
./tests/test_vbp_roundtrip.sh tests/vbp-roundtrip-js.manifest build/vbp-roundtrip-js
```
