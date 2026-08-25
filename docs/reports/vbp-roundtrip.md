# VBP round-trip — Vala / Gtk (this repo)

**Last run:** 2026-08-25. Manifest: `tests/vbp-roundtrip.manifest` (`all` under this repo).

Pipeline:

```
Start (.original.bjs)  →  Writer (.vbp)  →  Parser  →  End (.roundtrip.bjs)
```

**Acceptance for progress:** generated Vala equivalence — see [`vbp-roundtrip-generated.md`](vbp-roundtrip-generated.md).  
BJS JSON diffs (oid ignored) remain noisy and are not the gate.

| Check | Result |
|--|--|
| Parse `FAIL` | 0 |
| Content `GEN_DIFF` (canonical generated) | **4** — `CodeInfo`, `DialogFiles`, `DialogPluginWebkit`, `Editor` (construct/`init` braces) |
| Cache / multi-line method fixes | DialogConfirm-class and `DialogTemplateSelect` `showIt` OK |

**JS / Roo:** [`vbp-roundtrip-js.md`](vbp-roundtrip-js.md) · **Generated detail:** [`vbp-roundtrip-generated.md`](vbp-roundtrip-generated.md).

## Re-run

```
ninja -C build
./tests/test_vbp_roundtrip.sh tests/vbp-roundtrip.manifest build/vbp-roundtrip
```
