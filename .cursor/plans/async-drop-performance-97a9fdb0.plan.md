<!-- 97a9fdb0-75b8-495c-86bd-be70b0d7af6c c81cca81-9c79-414d-9361-698c33ffcd91 -->
# Optimize Node Drop Performance

## Problem Analysis

From the log analysis, the 4.4-second drop operation breaks down as:

- **2.6 seconds**: HTML/Preview generation (`toSourcePreview()`)
- **~400ms**: File serialization and save
- **~300ms**: Buffer update operations
- **Multiple redundant calls**: `transStringsToJs()` called 3 times

The main bottleneck is the preview HTML generation which happens synchronously during the drop.

## Solution

### 1. Defer Preview Generation (Option 1.a)

Make preview generation asynchronous/deferred until actually needed. The preview is only shown when the user switches to the preview tab, so we don't need to generate it immediately on every drop.

**Key insight**: `renderJS(force)` sets `refreshRequired = true`, then `runRefresh()` (called every 2 seconds) actually generates the preview. We should skip this during drop operations.

### 2. Make File Save Asynchronous (Option 2.b)

Make the file save operation asynchronous so it doesn't block the UI during the drop operation.

### 3. Trigger Source Highlighting After Async Operations

Since callers expect to highlight the selected node in source text after updates, we need to ensure `nodeSelected()` is called after the source code is regenerated.

## Implementation Steps

### Step 1: Add flag to skip preview generation during drops

**File**: `src/Builder4/WindowRooView.vala` (lines 758-770)

Add a flag to temporarily disable preview generation:

- Add `public bool skip_preview_generation` property
- Modify `renderJS()` to check this flag and return early if set
- This prevents the expensive `toSourcePreview()` call

### Step 2: Modify drop handler to defer preview

**File**: `src/Builder4/WindowLeftTree.vala` (lines 1142-1145)

After drop completes:

- Set `window_rooview.view.skip_preview_generation = true`
- Call `_this.changed()` (triggers async file save)
- Call `_this.node_selected(tadd)` (triggers source view update)
- Schedule preview generation for later with `GLib.Timeout.add()`
- Reset `skip_preview_generation = false` after delay

### Step 3: Make file save async

**File**: `src/JsRender/JsRender.vala` (lines 510-524)

Convert `save()` to async method:

- Change signature to `public async void save()`
- Use `Idle.add()` to defer actual file write
- Emit completion signal when done

### Step 4: Update changed() handler to handle async save

**File**: `src/Builder4/WindowState.vala` (lines 166-179)

Modify the `changed` signal handler:

- Call `file.save.begin()` instead of `file.save()`
- Use callback to trigger `requestRedraw()` after save completes
- This ensures source code is regenerated before highlighting

### Step 5: Ensure nodeSelected waits for source generation

**File**: `src/Builder4/WindowRooView.vala` (lines 1564-1619)

Add check in `nodeSelected()`:

- If source is still being generated, defer the highlighting
- Use a small timeout to retry until source is ready
- This ensures the line numbers are correct for highlighting

## Key Changes Summary

1. **WindowRooView.vala**: Add `skip_preview_generation` flag to defer expensive preview
2. **WindowLeftTree.vala**: Set flag during drop, schedule preview for later
3. **JsRender.vala**: Add mutex locking for thread-safe node access
4. **Roo.vala/Gtk.vala**: Add threaded `toSourceAsync()` and `toSourcePreviewAsync()` methods
5. **WindowState.vala**: Use async source generation in changed handler
6. **WindowRooView.vala**: Add async versions of requestRedraw and loadFile that use threads
7. **Thread Safety**: Mutex locks prevent node modifications during source generation

## Expected Performance Improvement

- Drop operation: **4.4s → ~500ms** (immediate UI response)
- Preview generation: Deferred until needed or after 2-second delay
- File save: Non-blocking (happens in background)
- Source highlighting: Works correctly after async operations complete

## Testing

After implementation, test:

1. Drop a node - should be instant
2. Check that file is saved correctly
3. Verify source highlighting works
4. Switch to preview tab - should generate preview on demand
5. Multiple rapid drops - should queue properly

### To-dos

- [ ] Add skip_preview_generation flag to WindowRooView and modify renderJS() to check it
- [ ] Modify drop handler in WindowLeftTree to set flag and schedule preview generation
- [ ] Convert save() method in JsRender.vala to async
- [ ] Update WindowState changed handler to use async save with callback
- [ ] Ensure nodeSelected() waits for source generation before highlighting