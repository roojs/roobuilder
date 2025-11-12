# Step 8 Incremental Restoration Plan

## Problem
Step 8 restoration broke the tree display. We need to restore Step 8 features incrementally to identify what broke.

## Starting Point
**Last Working Version:** `47b6a00e8` (fix-step-7-segfault: Restore rightpane creation for editor views)

## Goal
Restore Step 8 features one at a time, testing after each change to identify what breaks.

## Incremental Steps

### Step 8.1: File Dialog on Startup
**Goal:** Restore file dialog without breaking tree display

**Changes:**
- Restore `showPopoverFiles()` call in `MainWindow.show()`
- Disable auto-load test file

**Testing:**
- Application starts
- File dialog appears
- Tree displays correctly
- **Checkpoint:** Does tree still display?

**Git:** `git commit -m "restore-step-8.1-file-dialog" && git tag restore-step-8.1-file-dialog`

---

### Step 8.2: Node Selection Scrolling
**Goal:** Restore source view scrolling on node selection

**Changes:**
- Restore `node_selected` signal connection for scrolling in source view
- Add null checks for `file`

**Testing:**
- Select a node
- Verify source view scrolls to node
- Tree displays correctly
- **Checkpoint:** Does tree still display?

**Git:** `git commit -m "restore-step-8.2-node-scrolling" && git tag restore-step-8.2-node-scrolling`

---

### Step 8.3: Editor Source Check
**Goal:** Restore editor source check in before_node_change

**Changes:**
- Restore `before_node_change` check for editor source
- Check `lastEventSource == "editor"`

**Testing:**
- Trigger node change from editor
- Verify it's handled correctly
- Tree displays correctly
- **Checkpoint:** Does tree still display?

**Git:** `git commit -m "restore-step-8.3-editor-source-check" && git tag restore-step-8.3-editor-source-check`

---

### Step 8.4: showProps() Functionality
**Goal:** Restore property popover display

**Changes:**
- Restore `showProps()` implementation
- Exclude `rightpalete.hide()` (Step 9)

**Testing:**
- Call `showProps()`
- Verify popover displays
- Tree displays correctly
- **Checkpoint:** Does tree still display?

**Git:** `git commit -m "restore-step-8.4-show-props" && git tag restore-step-8.4-show-props`

---

### Step 8.5: showAddProp() Functionality
**Goal:** Restore property addition popover

**Changes:**
- Restore `showAddProp()` implementation
- Add string-to-NodePropType conversion

**Testing:**
- Call `showAddProp()`
- Verify popover displays
- Tree displays correctly
- **Checkpoint:** Does tree still display?

**Git:** `git commit -m "restore-step-8.5-show-add-prop" && git tag restore-step-8.5-show-add-prop`

---

### Step 8.6: switchState() Enhancements
**Goal:** Restore createThumb() calls

**Changes:**
- Restore `createThumb()` calls in `switchState()` for PREVIEW state
- Add null check for `getActiveFile()`

**Testing:**
- Switch to preview state
- Verify thumbnails are created
- Tree displays correctly
- **Checkpoint:** Does tree still display?

**Git:** `git commit -m "restore-step-8.6-switch-state-thumb" && git tag restore-step-8.6-switch-state-thumb`

---

### Step 8.7: Changed Signal Enhancements
**Goal:** Restore async source regeneration

**Changes:**
- Restore `requestRedraw()` and `loadFile()` calls in changed signal
- Add file type checks

**Testing:**
- Make a change to tree
- Verify source regeneration
- Tree displays correctly
- **Checkpoint:** Does tree still display?

**Git:** `git commit -m "restore-step-8.7-changed-signal" && git tag restore-step-8.7-changed-signal`

---

### Step 8.8: Pane Visibility Management (PROBLEMATIC)
**Goal:** Restore pane visibility logic in leftTreeNodeSelected

**Changes:**
- Restore pane visibility management
- Restore tree/widget reparenting based on node selection
- Restore pane position management
- **CRITICAL:** Ensure initial tree placement matches master

**Testing:**
- Select a node
- Verify properties panel shows
- Deselect node (sel == null)
- Verify properties panel hides
- Tree displays correctly at all times
- **Checkpoint:** Does tree still display?

**Git:** `git commit -m "restore-step-8.8-pane-visibility" && git tag restore-step-8.8-pane-visibility`

**Note:** This step is likely where the tree disappeared. We need to be very careful about:
- Initial tree placement in `leftTreeInit()`
- Tree reparenting in `leftTreeNodeSelected()`
- Ensuring tree is always visible

---

## Testing Protocol

After each step:
1. **Build:** `ninja -C build`
2. **Run:** `./build/roobuilder`
3. **Test:**
   - Verify tree displays on startup
   - Test the new feature
   - Verify tree still displays after feature use
   - Test drag-and-drop still works
4. **If tree disappears:**
   - Note which step caused it
   - Rollback to previous step
   - Investigate the specific change
   - Fix before proceeding

## Rollback Strategy

If a step breaks the tree:
- Use `git checkout <previous-tag>` to rollback
- Investigate the specific changes in that step
- Fix the issue before proceeding
- May need to split the step further

## Success Criteria

✅ **Success:** All Step 8 features restored without breaking tree display
✅ **Success:** Tree displays correctly at all times
✅ **Success:** Drag-and-drop still works
✅ **Success:** All features function correctly

