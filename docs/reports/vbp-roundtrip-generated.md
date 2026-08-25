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

`DialogTemplateSelect` `showIt` VBP is now:

```
void showIt (
  Xcls_MainWindow mwindow,
  …
) {
  this.el.show();
  …
}
```

---

## Vala — still `GEN_DIFF` (4)

`CodeInfo`, `DialogFiles`, `DialogPluginWebkit`, `Editor`.

Construct/`init` brace wrapping: expected still has an extra `{ … }` around some init bodies that round-trip drops (or the reverse). Not missing methods — brace placement in generated Vala.

```vala
// expected
this.el = new WebKit.WebView();
{
var settings = this.el.get_settings();
```

```vala
// got
this.el = new WebKit.WebView();
var settings = this.el.get_settings();
```

`DialogConfirm`, `About`, `EditProject`, save dialogs, `DialogTemplateSelect`: content match under canonical compare.

---

## JS — still broken where it matters

### Parse failures (22)

Tokenizer/opaque-brace issues, e.g. `Unclosed opaque brace block`, `Unmatched }`, `Unmatched ]` — including `Pman.Tab.CrmClient.bjs`.

### Content `GEN_DIFF` (208) — typical patterns

**Object literal quoted as a string** (`AdminEventLog`):

```js
// expected
sortInfo : { field : 'event_when', direction: 'DESC' },
```

```js
// got
sortInfo : '{ field : \'event_when\', direction: \'DESC\' }',
```

**i18n / `_strings` mishandled** (`AdminAddIpv6`):

```js
// expected
loadingText : _this._strings['1243daf593…'] /* Searching... */,
```

```js
// got
loadingText : Searching...,
```

**Large structured RAW props** (e.g. `fields : [ … ]`) still drop or flatten — same family as quoting objects.

---

## Next work

1. **JS parse:** opaque `{` / `]` matching on the FAIL set (start with CrmClient / NotifySender).
2. **JS content:** stop quoting/flattening object and array RAW values; keep `_strings` wiring.
3. **Vala:** construct/`init` outer braces in generated output (the remaining 4).

## Re-run

```bash
ninja -C build
./tests/test_vbp_roundtrip.sh tests/vbp-roundtrip.manifest build/vbp-roundtrip
./tests/test_vbp_roundtrip.sh tests/vbp-roundtrip-js.manifest build/vbp-roundtrip-js
grep '^GEN_DIFF \|^FAIL ' /tmp/rt-*.log
```
