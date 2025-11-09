<!-- 433eabba-8434-4157-b03d-f483f627ddf4 dc139061-576a-41c7-a049-43c7a4b6ef2a -->
# Fix drag_motion Not Firing on First Entry

## Problem Analysis

The issue is that:

- First drag works correctly
- Subsequent drags: first entry into WindowLeftTree fires `drag_enter` but `drag_motion` doesn't fire until moving away and back again

**Key observation**: `drag_enter` fires but `drag_motion` doesn't on first entry. This suggests the drop target is being entered, but motion events aren't being delivered.

**Possible root causes:**

1. **accept() method issue**: In GTK4, `accept()` must be called and return `true` for `drag_motion` to fire. If `accept()` isn't being called on subsequent drags, or if there's some state preventing it from working, motion events won't fire.

2. **drag_enter return value**: The `drag_enter` handler returns `Gdk.DragAction.MOVE`, but maybe it needs to match the actual drag action being offered, or return a different value.

3. **DropTargetAsync state**: The DropTargetAsync might retain some state from the previous drag that prevents it from accepting motion events on the first entry of a new drag.

4. **Content provider not ready**: On first entry, the content provider might not be ready yet, causing `accept()` to fail silently or return false.

## Solution Approaches to Try

### Approach 1: Add debug logging and verify accept() is called

- Add debug logging to `accept()` to verify it's being called on subsequent drags
- Check if `accept()` returns true on subsequent drags
- Verify the content formats match

### Approach 2: Reset state in drag_enter

- In `drag_enter`, explicitly reset any cached state
- Ensure `lastDragString` and `lastDragNode` are cleared
- Force re-evaluation of the drop target

### Approach 3: Check drag_enter return value

- Verify `drag_enter` returns the correct drag action
- Try returning `Gdk.DragAction.COPY | Gdk.DragAction.MOVE` instead of just `MOVE`
- Ensure it matches what the DragSource is offering

### Approach 4: Force accept in drag_enter

- In `drag_enter`, explicitly call `accept()` or ensure the drop target is ready
- This might help if there's a timing issue

## Files to Modify

1. **src/Builder4/WindowLeftTree.vala** (lines 1503-1906)

- Add debug logging to `accept()` method
- Modify `drag_enter` to reset state and/or return different value
- Add logging to track when `accept()` is called vs when `drag_motion` should fire

2. **src/Builder4/WindowLeftTree.bjs** (lines 1031-1044)

- Same changes as in .vala file

## Implementation Details

### Debug and fix approach:

- Add `GLib.debug("DropTargetAsync: accept called on drag %p", drop);` in accept()
- In `drag_enter`, add: `this.lastDragString = ""; this.lastDragNode = null;` to reset state
- Try returning `Gdk.DragAction.COPY | Gdk.DragAction.MOVE` from `drag_enter` instead of just `MOVE`
- Add debug logging to see the sequence: accept -> drag_enter -> drag_motion (or lack thereof)