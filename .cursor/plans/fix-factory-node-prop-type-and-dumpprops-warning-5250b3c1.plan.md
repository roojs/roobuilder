<!-- 5250b3c1-e0a0-42d7-a028-cf1f6fa14d05 8f5bfc8b-6149-4388-9e29-cfab8efcf250 -->
# Fix xtype and xns appearing as properties instead of prop_type

## Issues

1. **xns and xtype appearing as properties**: In dumpProps() output, `p xns = Gtk` and `p xtype = ScrolledWindow` are showing up as regular properties instead of being consumed to set `prop_type = "Gtk.ScrolledWindow"`.
2. **Factory node missing prop_type**: Child nodes with `"* prop": "factory"` may not have prop_type set correctly, causing "Could not find class" error during Vala code generation.

## Root Cause Analysis

- In `FileLegacy.loadFromJson()`, the first pass (lines 36-51) collects `xns` and `xtype` values, but only sets `prop_type` if BOTH are non-empty (line 54).
- The second pass (lines 95-100) should skip `"xtype"`, `"$ xtype"`, `"* xns"`, `"*xns"`, and `"$ xns"`.
- However, if the keys don't match exactly (e.g., just `"xns"` without `"$ "` prefix), they fall through to the default case and become NodeProp objects.focus on filelegacy only - 
- The issue might also occur if the keys are processed before prop_type is set, or if there's a case sensitivity/whitespace issue.

## Solution

### Fix 1: Add "xns" (without prefix) to switch cases

In `src/JsRender/FileLegacy.vala`, add `"xns"` (without any prefix) to both the first pass switch (line 38) and second pass switch (line 95) to handle cases where xns might appear without the "$ " prefix.

### Fix 2: Ensure xtype/xns are never added as properties

In the second pass, if we encounter keys that could be xns/xtype variants, make sure we skip them even if they don't match exactly. Consider using string matching (e.g., `key.has_suffix("xns")` or `key.has_suffix("xtype")`) as a fallback.

### Fix 3: Fix dumpProps() null check

In `src/JsRender/Node.vala` around line 319-320, add a null check after casting to NodeProp before accessing its properties.

### Fix 4: Improve error handling in NodeToValaWrapped

In `src/JsRender/NodeToValaWrapped.vala` around line 238-240, add better error context showing prop_name and fqn() when prop_type is missing.

## Implementation Details

- Update FileLegacy.loadFromJson() first pass to detect type-prefixed keys (e.g., `"string xns"`, `"string xtype"`) by checking if key ends with `" xns"` or `" xtype"`
- Extract the actual property name from type-prefixed keys (split by space and take the last part)
- Update second pass to skip type-prefixed xns/xtype keys
- Remove the error at line 64 (it should only be a warning or debug message, not a fatal error)
- Fix dumpProps() to safely handle Node objects in cache
- Improve error messages for debugging prop_type issues