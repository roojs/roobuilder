<!-- 26633893-e304-4c2b-a8d8-fd24c2675b91 52332111-3313-444a-be23-d4c8f697fd80 -->
# Fix BJS File Compilation Triggers

## Problem

BJS files (user interface files) in Gtk projects are not triggering background compilation when:

1. Opened - `LanguageClientVala.document_open()` returns early because `isReady()` is false, so compilation never starts
2. Edited - Changes don't trigger compilation, so errors are never updated

## Error Update Flow (for reference)

When compilation completes successfully:

1. `ValaSymbolBuilder.updateBackground()` compiles and stores errors in `this.errors` map (keyed by file path)
2. `updateTree()` callback (line 139-162) calls `f.updateErrors()` for each file in `this.files`
3. `JsRender.updateErrors()` updates the file's error list and calls `WindowManager.updateCompileResults()` if error count changed
4. `WindowManager.updateCompileResults()` (debounced) eventually calls `realUpdateCompileResults()`
5. `realUpdateCompileResults()` updates all UI: error marks, main window, left tree, left props

**Issue**: For BJS files, compilation never starts, so `updateErrors()` is never called, and errors never appear in the UI.

## Solution

Add calls to `file.update_symbol_tree()` where `document_open()` and `document_change()` are called. This method already handles the Gtk project check internally (it only triggers for Gtk projects), so no additional checks are needed.

## Changes Required

### 1. WindowState.vala - Trigger compilation on file open

**Location**: `src/Builder4/WindowState.vala` around line 708

After `document_open()` is called, trigger compilation:

```708:710:src/Builder4/WindowState.vala
file.getLanguageServer().document_open(file);
WindowManager.showSpinner("spinner", "document open sent");
file.update_symbol_tree();
```

### 2. Palete.vala - Trigger compilation on file edit

**Location**: `src/Palete/Palete.vala` around line 193

After `document_change()` is called for non-PlainFile files, trigger compilation:

```193:195:src/Palete/Palete.vala
editor.file.getLanguageServer().document_change(editor.file);
editor.file.update_symbol_tree();
```

## Testing

1. Open a BJS file - should see compilation activity in logs
2. Edit a BJS file - should trigger recompilation
3. Verify `/tmp/compile-ok.log` shows compilation activity for BJS files (similar to Vala files)