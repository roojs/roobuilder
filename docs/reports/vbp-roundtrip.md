# VBP round-trip — test status

**Last run:** 2026-08-19 (`ninja -C build`, then `--test-vbp-roundtrip` on v3 corpus).

**Corpus:** this repo, **BJS v3 only**. v1 `items` files are skipped (`SKIP … (bjs-version N)`). Four v3 files:

| File | Strict diff (`oid` ignored) | Child order | Notes |
|------|----------------------------:|-------------|-------|
| `PopoverProperty.bjs` | 18 | match | smallest gap |
| `PopoverAddObject.bjs` | 63 | match | |
| `DialogFiles.bjs` | 74 | match | |
| `WindowRooView.bjs` | 188 | match | largest file |

**Result:** **0 / 4 identical.** None pass `tests/test_vbp_roundtrip.sh` (strict `diff -u` on `.original.bjs` vs `.roundtrip.bjs`).

Artifacts: `build/vbp-roundtrip/roobuilder/src/Builder4/{file}.original.bjs`, `.vbp`, `.roundtrip.bjs`.

`node-type` (`JsRender.NodePropType`): **2 PROP**, **3 RAW**, **4 METHOD**, **5 SIGNAL**, **6 USER**, **7 SPECIAL**, **8 LISTENER**, **9 OBJECT**.

---

## How to run

```bash
ninja -C build
build/roobuilder --project /home/alan/gitlive/roobuilder \
  --test-vbp-roundtrip src/Builder4/PopoverProperty.bjs \
  --vbp-roundtrip-dir build/vbp-roundtrip

# or all v3+v1 (v1 skipped) via manifest:
tests/test_vbp_roundtrip.sh
```

Round-trip harness applies `GtkPropTypes` to **both** sides before writing `.original.bjs`, so type diffs are Gir/instance-field issues, not “original had type, snapshot didn’t”.

---

## Fixed (or no longer a top-level failure)

### 1. Child order

Writer now walks `node.children` in **source order** (no bucket sort). All four files: same `prop-name` sequence top-level.

Previously the writer reordered into `id` / props / `var` / `listeners` / `methods` / children, which made index diffs look like wrong nodes.

### 2. Quoted strings with `(` — label round-trip

Writer now quotes values like `Property Type (eg. property or method)` instead of leaving them unquoted.

**VBP now:**

```
string label = "Property Type (eg. property or method)";
```

**Original and round-trip both:**

```json
{
  "node-type": 2,
  "prop-name": "label",
  "prop-val": "Property Type (eg. property or method)",
  "prop-type": "string"
}
```

### 3. Instance / typed props on write; Gir refill on parse

Writer emits explicit types where safe (`bool done = false;`, `Xcls_MainWindow mainwindow;`). Parser accepts `Type name = value;` and `Type name;`. `GtkPropTypes` still fills real Gtk props on parse.

**`done` / `is_new` — match:**

```json
{ "node-type": 2, "prop-name": "done", "prop-val": false, "prop-type": "bool" }
```

**`mainwindow` on `PopoverAddObject` — match:**

```json
{ "node-type": 2, "prop-name": "mainwindow", "prop-type": "Xcls_MainWindow" }
```

**`ctor` spacing — fixed when quoted in VBP:**

```
ctor = "new Gtk.Popover()";
```

```json
{ "node-type": 7, "prop-name": "ctor", "prop-val": "new Gtk.Popover()" }
```

### 4. Listener names with `[` — `notify["selected"]`

Writer quotes listener names that contain `[` / `]` so the tokenizer does not split them. Name round-trips; body issues remain (below).

---

## Still failing

Grouped by diff category across the four files (~343 strict diffs total):

| Category | ~count | What it means |
|----------|-------:|---------------|
| **body_shape** | 121 | BJS **line array** → round-trip **one string** (methods, listeners, `init`, inline RAW blocks) |
| **other** | 189 | Mostly per-line body text changes inside those collapsed strings (comments/blank lines merged or lost) |
| **prop_vs_raw** | 25 | Original **RAW** (`node-type` 3), round-trip **PROP** + Gir type (usually `visible`) |
| **spaces** | ~0 (signatures) | ~~Spaces eaten in method/signal signatures~~ — **fixed** (tokenizer emits `WS` tokens; parser rejoins verbatim) |
| **type_missing** | 1 | Generic type not written (`Gee.HashMap<…>`) |
| **node_type** | 1 | SPECIAL → PROP with same value (e.g. HeaderBar `title`) |

### A. Method / listener / init bodies — **whitespace issue (writer side)**

Two parts:

1. **Parser (fixed):** tokenizer `WS` tokens + `join_nodes` — signatures and in-body spaces/tabs/newlines are preserved when reading VBP.
2. **Writer (fixed):** was calling `.strip()` on bodies and prefixing every continuation line with `list_pad` / `child_pad`. That VBP layout padding was read back into `prop_val`, so BJS line arrays gained extra leading spaces (e.g. `"                \t_this.prop = null;"` vs `"\t_this.prop = null;"`).

Writer now emits opaque bodies **verbatim** (`put_opaque_body`) — no strip, no re-indent.

**Listener `clicked` on `PopoverProperty` — now matches:**

```json
"prop-val": [
  "() => {",
  "\t_this.prop = null;",
  "\t_this.is_new = false;",
  ...
]
```

**Still failing in bodies:** `//` line comments inside `{ … }` are dropped by the tokenizer (`//` tokens are kept off the tree). Blank lines and comment-only lines can still differ on large methods (e.g. `WindowRooView.highlightErrors`).

### B. Spaces in method signatures (`methods [` peers) — **fixed**

Tokenizer emits `WS` tokens for space/tab/newline runs; structural parsing skips them, `join_nodes` includes them. Example: `void success (Project.Project pr, JsRender.JsRender file)` round-trips with spaces intact.

### C. PROP vs RAW

**Rule:** if the RHS starts and ends with a quote, it is **PROP** (a string), never RAW. Writer: quote-wrapped RAW values are emitted as PROP assignments. Parser: same check before the expression heuristic.

Unquoted RHS with `(`, `{`, or a newline is **RAW** (code). Unquoted bools / numbers / enums are **PROP**.

So `label = "Cancel";` is PROP. `strings = JsRender.NodePropType.get_pulldown_list();` is RAW. `visible = true;` is PROP even when legacy BJS had RAW — same value, same Vala output; ignorable for codegen.

**Original (legacy RAW bool):**

```json
{ "node-type": 3, "prop-name": "visible", "prop-val": true }
```

**Round-trip:**

```json
{ "node-type": 2, "prop-name": "visible", "prop-val": true, "prop-type": "bool" }
```

### D. Generic / SPECIAL types not preserved

**`Gee.HashMap<string,Gdk.Pixbuf>` on `DialogFiles.image_cache`** — writer skips typed form when type contains `<` (not emitted as `Type name;`). VBP:

```
image_cache;
```

Round-trip loses `prop-type` (not a Gtk property; Gir does not refill).

**HeaderBar `title`** — value matches; classification changes SPECIAL → PROP because VBP uses quoted string assignment:

```
titlebar = Gtk.HeaderBar {
  title = "Select Project / File";
```

```json
{ "node-type": 7, "prop-name": "title", "prop-val": "Select Project / File" }
```

```json
{ "node-type": 2, "prop-name": "title", "prop-val": "Select Project / File" }
```

### E. Construct blocks + comments

**`PopoverAddObject`** — `construct { … }` with leading comment lines: round-trip merges/splits lines differently (blank/`/*` line becomes `{/*` in array form). Contributes to **body_shape** / **other** on that subtree.

---

## Suggested next fixes (no new syntax unless plan-approved)

1. ~~**Spaces**~~ — done (`WS` tokens in tokenizer).
2. ~~**Bodies — layout padding**~~ — writer `put_opaque_body` (no `list_pad` injection).
3. **Bodies — `//` comments inside opaque `{ … }`** — tokenizer skips `//` in tree; needs plan if comments must round-trip.
4. ~~**RAW vs PROP (quoted ⇒ not RAW)**~~ — quote-delimited RHS is PROP; remaining flips are legacy unquoted bools/enums.
5. **Generics** — emit `Gee.HashMap<string,Gdk.Pixbuf> image_cache;` (parser already has `Type name;`).

---

## Per-file quick view

### `PopoverProperty.bjs` (18 diffs) — closest

| Area | Status |
|------|--------|
| Child order | pass |
| Label quoting | pass |
| `done` / `is_new` / `mainwindow` types | pass |
| `ctor` | pass |
| `success` signature spaces | **pass** |
| `visible` RAW→PROP | **fail** (×6) |
| Listener/method bodies array→string | **fail** |

### `PopoverAddObject.bjs` (63 diffs)

| Area | Status |
|------|--------|
| Child order | pass |
| `mainwindow` type | pass |
| Signal signature spaces | **pass** |
| `construct` + CSS comment block | **fail** |
| Method/listener bodies | **fail** |

### `DialogFiles.bjs` (74 diffs)

| Area | Status |
|------|--------|
| Child order | pass |
| `init` body | **fail** (array→string) |
| `image_cache` generic type | **fail** |
| HeaderBar `title` node-type | **fail** (value OK) |
| Nested RAW/method bodies | **fail** |

### `WindowRooView.bjs` (188 diffs)

| Area | Status |
|------|--------|
| Child order | pass |
| Many nested `visible` RAW→PROP | **fail** |
| Large method bodies (e.g. `highlightErrors`) | **fail** (array→string + line loss) |
