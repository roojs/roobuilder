# Gradual Feature Restoration Plan

## Overview

After successfully stripping down roobuilder to a minimal working state with `WindowLeftTree` and dummy nodes (tagged as `base-working-version`), we will gradually restore features one at a time. After each restoration step, we will test drag-and-drop functionality to identify what causes the 2nd drag failure issue.

## Current State (base-working-version)

✅ **Working:**
- WindowLeftTree displays dummy nodes
- Basic drag-and-drop functionality works
- Selection handling works
- No file dialog on startup
- All startup crashes resolved

❌ **Removed:**
- File loading (`loadFile()`)
- Error handling (`updateErrors()`, `ListView12`)
- Context menu (`LeftTreeMenu`)
- Properties panel (`editpane`, `props`)
- Editor views (`codeeditviewbox`, `rooviewbox`, `gladeviewbox`)
- Signal connections to file operations
- PopoverAddObject integration
- Post-drop behavior (action_manager, file.save(), etc.)

## Restoration Steps

### Step 1: File Loading
**Goal:** Restore ability to load actual files instead of dummy nodes

**Changes:**
- Uncomment `loadFile()` in `Xcls_model`
- Restore `getActiveFile()` method
- Update `createDummyData()` to use actual file loading
- Restore file-related signal connections in `WindowState.leftTreeInit()`

**Testing:**
- Load a test file
- Verify tree displays correctly
- Test drag-and-drop with real nodes
- **Checkpoint:** Does drag-and-drop still work?

**Git:** `git commit -m "restore-step-1-file-loading" && git tag restore-step-1-file-loading`

---

### Step 2: Post-Drop Behavior (PRIORITIZED)
**Goal:** Restore post-drop actions (action_manager, file.save(), etc.) to identify what breaks drag-and-drop

**Changes:**
- Restore `action_manager` calls in `drop()` method
- Restore `file.save()` calls after drop
- Restore `changed()` signal emission
- Restore `before_node_change` signal handling
- Restore `node_selected` signal with file operations

**Testing:**
- Perform first drag-and-drop
- **Critical:** Test second drag-and-drop immediately after
- **Checkpoint:** Does 2nd drag fail? If yes, we've found the culprit!

**Git:** `git commit -m "restore-step-2-post-drop-behavior" && git tag restore-step-2-post-drop-behavior`

---

### Step 3: Error Handling
**Goal:** Restore error display functionality

**Changes:**
- Restore `Xcls_ListView12` (error list)
- Restore `updateErrors()` and `removeErrors()` methods
- Restore error signal connections
- Restore `error_widgets` management

**Testing:**
- Verify errors display correctly
- Test drag-and-drop with error handling active
- **Checkpoint:** Does drag-and-drop still work?

**Git:** `git commit -m "restore-step-3-error-handling" && git tag restore-step-3-error-handling`

---

### Step 4: Context Menu
**Goal:** Restore right-click context menu

**Changes:**
- Restore `Xcls_LeftTreeMenu` initialization
- Restore menu button click handlers
- Restore menu item actions

**Testing:**
- Right-click on nodes
- Verify menu appears
- Test drag-and-drop with menu enabled
- **Checkpoint:** Does drag-and-drop still work?

**Git:** `git commit -m "restore-step-4-context-menu" && git tag restore-step-4-context-menu`

---

### Step 5: Signal Connections
**Goal:** Restore all signal connections for file operations

**Changes:**
- Restore `before_node_change` signal connection
- Restore `node_selected` signal connection with full file operations
- Restore `changed` signal connection
- Restore editor view signal connections

**Testing:**
- Verify signals fire correctly
- Test drag-and-drop with all signals active
- **Checkpoint:** Does drag-and-drop still work?

**Git:** `git commit -m "restore-step-5-signal-connections" && git tag restore-step-5-signal-connections`

---

### Step 6: Properties Panel
**Goal:** Restore properties editing panel

**Changes:**
- Restore `Xcls_editpane` creation in `MainWindow`
- Restore `Xcls_props` creation
- Restore `propsListInit()` in `WindowState`
- Restore `left_props.load()` calls
- Restore properties panel signal connections

**Testing:**
- Select a node
- Verify properties panel shows
- Edit properties
- Test drag-and-drop with properties panel visible
- **Checkpoint:** Does drag-and-drop still work?

**Git:** `git commit -m "restore-step-6-properties-panel" && git tag restore-step-6-properties-panel`

---

### Step 7: Editor Views
**Goal:** Restore code editor and preview views

**Changes:**
- Restore `codeeditviewbox` creation
- Restore `rooviewbox` and `gladeviewbox` creation
- Restore `codeEditInit()`, `webkitViewInit()`, `gtkViewInit()`
- Restore editor view signal connections
- Restore `getActiveFile()` calls for views

**Testing:**
- Open code editor
- Switch to preview views
- Test drag-and-drop with views active
- **Checkpoint:** Does drag-and-drop still work?

**Git:** `git commit -m "restore-step-7-editor-views" && git tag restore-step-7-editor-views`

---

### Step 8: Full Feature Set (EXCEPT PopoverAddObject)
**Goal:** Restore any remaining features except PopoverAddObject

**Changes:**
- Restore any remaining commented-out code
- Restore file dialog on startup (if needed)
- Restore any other missing features
- **EXCLUDE:** PopoverAddObject integration (moved to Step 9)

**Testing:**
- Full application testing (without popover)
- Test all drag-and-drop scenarios
- **Checkpoint:** Does drag-and-drop work in all cases?

**Git:** `git commit -m "restore-step-8-full-features" && git tag restore-step-8-full-features`

---

### Step 9: PopoverAddObject Integration (LAST STEP - HAS KNOWN ISSUES)
**Goal:** Restore object addition popover

**Status:** ⚠️ **KNOWN ISSUES** - Secondary drag-and-drop from popover has issues that need to be dealt with separately

**Changes:**
- Restore `PopoverAddObject` signal connections
- Restore `showAddObject()` calls
- Restore palete integration
- Restore node addition via drag from palete
- Restore column click to trigger popover

**Testing:**
- Open add object popover
- Add objects via drag-and-drop from palete
- Test tree drag-and-drop with popover active
- **Known Issue:** Secondary drag-and-drop from popover fails - needs separate investigation

**Git:** `git commit -m "restore-step-9-popoveraddobject" && git tag restore-step-9-popoveraddobject`

**Note:** This step has known issues with secondary drag-and-drop operations from the popover. These should be investigated and fixed separately after completing the main restoration process.

---

## Testing Protocol

After each restoration step:

1. **Build:** `ninja -C build`
2. **Run:** `./build/roobuilder`
3. **Test Drag-and-Drop:**
   - Select a node
   - Drag it to another location (first drag)
   - **Immediately** select another node
   - Drag it to another location (second drag)
   - **Critical:** Does the second drag work?
4. **If drag-and-drop breaks:**
   - Note which step caused the break
   - Investigate what changed in that step
   - This identifies the root cause of the 2nd drag failure

## Rollback Strategy

If a step breaks drag-and-drop:
- Use `git checkout <previous-tag>` to rollback
- Investigate the specific changes in that step
- Fix the issue before proceeding

## Success Criteria

✅ **Success:** We identify exactly which feature/change causes the 2nd drag failure
✅ **Success:** We can fix the issue while keeping other features
✅ **Success:** Full application works with drag-and-drop functioning correctly

## Notes

- **Step 2 is prioritized** because post-drop behavior is most likely to affect subsequent drags
- Each step should be small and focused
- Test thoroughly after each step
- Document any issues found during restoration
- Keep the base-working-version tag as a safe rollback point

