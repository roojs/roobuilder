# VBP round-trip — Generated Output Equivalence

Judge success by whether generated Vala/JS still means the same thing after BJS→VBP→BJS.

`GEN_DIFF` compares a **canonical** form (whitespace, `//` comments, empty `{}`, and `Xcls_*`/`child_*` number suffixes stripped). Formatting-only churn does not count.

Artifacts when readable sources differ: `*.original.generated.*` / `*.roundtrip.generated.*`.

**Last run:** 2026-08-25 (after `add_to_cache`, multi-line `CodeParts` split, `) {` emit, wrap helpers removed).

---

## Snapshot

| | Vala (this repo) | JS (Pman manifest) |
|--|--|--|
| Parse `FAIL` | 0 | **22** (opaque brace / unmatched `}` `]`) |
| Content `GEN_DIFF` | **4** | **208** |
| Fixed since cache bug | DialogConfirm-class missing props/listeners/methods | Same class of empty-cache drops gone where parse succeeds |

BJS JSON identity (oid ignored) is still dirty for Vala — that is **not** the acceptance gate. Generated content is.

---

## Fixed (do not regress)

1. **`Parser.add_child` → `add_to_cache`** — codegen reads `props`/`listeners` from cache; children alone were not enough.
2. **`CodeParts.from_prop_val`** — body opens at first `{` at paren-depth 0 (multi-line parameter lists).
3. **Standard emit** — `header {\nbody\n}` with `) {` / `=> {` on one line. Writer prints stored `code_header`/`code_body` as-is (no re-wrap trickery). `CodeParts` is for legacy BJS recovery + that join only.

---

## Vala — the remaining 4 (`GEN_DIFF`)

Files: `CodeInfo`, `DialogFiles`, `DialogPluginWebkit`, `Editor`.

### What it is *not*

Not missing methods/props. Not `Xcls_Box8` vs `Xcls_Box45` (canonical strips those). Mostly **author-written Vala `{ }` block scopes inside `init`** that round-trip drops.

### Why braces appear / disappear

Legacy BJS stores `init` as a string **array**. Some authors wrapped the body in a Vala block:

**Original BJS** (`DialogPluginWebkit` → WebKit.WebView `init`):

```json
"prop-name": "init",
"prop-val": [
  " {",
  "    // this may not work!?",
  "    var settings =  this.el.get_settings();",
  "    …",
  " }"
]
```

Those leading/trailing `{` / `}` are **part of the code**, not VBP syntax.

**`CodeParts.for_prop` for `init`** treats a whole value that starts with `{` and ends with `}` as “CodeParts wrappers” and **strips** them before VBP write:

```vala
// after normalize — braces gone from prop_val / code_body
var settings = this.el.get_settings();
…
```

**VBP** (correct for the stripped body):

```
WebKit.WebView {
  construct
  {
    // this may not work!?
    var settings = this.el.get_settings();
    …
  }
}
```

Parser: `construct { … }` braces are VBP shell only → `init` body without an extra block.

**Generated Vala**

| | After `this.el = new WebKit.WebView();` |
|--|--|
| original | `{` … settings / FakeServer … `}` (block from BJS) |
| round-trip | statements directly (no block) |

Same pattern elsewhere: empty `{` / `}` after a statement (`CodeInfo` `this.loaded = false;`), or a one-liner wrapped in braces (`Editor` `this.el.show();`). Canonical removes empty `{}` pairs; **braces that wrap real statements stay** in the compare → `GEN_DIFF`.

Semantically those blocks are usually no-ops (extra scope). Still a real fidelity gap if we care about byte-stable generated Vala.

### Open fix directions (not decided)

- Stop stripping outer `{`…`}` on `init` when they were author code (hard to tell from CodeParts delimiters).
- Or accept strip + teach canonical that a lone block around construct body is equivalent (weaker).
- Or emit `construct` body exactly as stored and never normalize `init` through the method-shaped CodeParts strip.

---

## JS — RAW object / array literals (`sortInfo`, `fields`)

### Pipeline today

**Original BJS:** `sortInfo` is **RAW** (`$`) with value `{ field : 'event_when', direction: 'DESC' }`.

**Writer** (deliberate): if RAW contains `{` / `}` or a newline, **quote it as a shell string** so a bol `{` is not taken as an opaque code block:

```
sortInfo = "{ field : 'event_when', direction: 'DESC' }";
```

Multiline arrays become:

```
fields = "[
    {
        'name': 'id',
        …
";
```

**Parser:** quote-delimited RHS → **PROP** (string), not RAW.

**Generated JS**

| | |
|--|--|
| expected | `sortInfo : { field : 'event_when', direction: 'DESC' },` |
| got | `sortInfo : '{ field : \'event_when\', direction: \'DESC\' }',` |

Quoting “fixed” the tokenizer collision and **broke** codegen: RAW expression → string literal.

### Lean RAW fence — `@[` / `@{` (scope from corpus)

See [`1.0-vbp-format.md`](../plans/1.0-vbp-format.md). ~1250 JS hits whose RAW/PROP text starts with `[` or `{`: mostly **`fields`** (~600) and **`sortInfo`** (~500), then `data`, `baseParams`, and a short tail. Out of scope: `url` / `renderer` expressions, `construct`, quoted format strings like `"{0}"`.

```
sortInfo = @{ field : 'event_when', direction: 'DESC' };

fields = @[
    { name: 'id', type: 'int' },
    …
];
```

`@` = nested `[`/`{` is RAW, not VBP structure. **🚫** quoting; **🚫** `@"""`.

---

## JS — i18n / `_strings` (`loadingText`)

### How codegen works today (BJS path)

1. Plain **PROP** string on a name in `doubleStringProps` (e.g. `loadingText`) or `_…` string type.
2. On generate, `NodeToJs` emits `_this._strings['«md5»'] /* Searching... */`.
3. `Roo.findTransStrings` / `transStringsToJs` builds the `_strings` / `_named_strings` maps from the same plain text (MD5 of stripped value).
4. **Translation tooling still keys off BJS** (plain source strings in the tree) — checksums are derived at generate time, not stored as the authoring source of truth.

### What VBP does wrong now

```
loadingText = Searching...;
```

Unquoted → parsed as **RAW** → codegen prints `loadingText : Searching...,` (no quotes, no `_strings`).

Expected:

```
loadingText : _this._strings['1243daf593…'] /* Searching... */,
```

Minimum fix: Writer must emit **quoted** PROP strings (`loadingText = "Searching...";`) so type stays PROP and the existing `_strings` path runs.

### 💩 Open: VBP strings header (checksum section)

Outbound translation still wants a stable extractable string table. Options:

1. **Keep deriving** checksums only at generate time from quoted PROP values (status quo once quoting is fixed). BJS/VBP hold plain text; no checksums in the file.
2. **VBP header section** listing checksum → text (and maybe named keys), e.g.

```
vbp-version = 1;
name = Pman.Dialog.AdminAddIpv6;
strings {
  "1243daf593…" = "Searching...";
  // or named: domain_id_domain_loadingText = "1243daf593…";
}
```

- **Load:** read `strings { }`, keep map on `JsRender`; when injecting/generating, prefer header map (or validate against MD5 of PROP text).
- **Write:** emit header from `transStrings` / named map after a generate or save pass.
- **Translation:** either keep using BJS for extract, or teach the extractor to read this VBP header (and stop requiring BJS for that).

Question for product: is the header the **source of truth** for translators, or only a cache that must match PROP text? If source of truth, PROP values might become references (`loadingText = string "1243…";`) instead of duplicating text — bigger format change.

---

## Next work

1. **Vala:** decide keep vs strip author `{ }` inside `init` (see above) — unblocks the 4 `GEN_DIFF`s.
2. **JS RAW:** design fence / `name = [ … ];` expression so `sortInfo` / `fields` stay RAW (plan open point in `1.0-vbp-format.md`).
3. **JS strings:** quote PROP strings in Writer; then decide whether a `strings { }` header is worth it for translation.
4. **JS parse FAIL (22):** opaque brace / unmatched `}` `]` (CrmClient, etc.).

## Re-run

```bash
ninja -C build
./tests/test_vbp_roundtrip.sh tests/vbp-roundtrip.manifest build/vbp-roundtrip
./tests/test_vbp_roundtrip.sh tests/vbp-roundtrip-js.manifest build/vbp-roundtrip-js
grep '^GEN_DIFF \|^FAIL ' /tmp/rt-*.log
```
