<!-- fcfd96a3-5503-4c5c-ab64-00ca32c65d68 b8de8875-f1de-4ba1-8676-0d3c2338eec3 -->
# Fix Drag Event Handling Between PopoverAddObject and WindowLeftTree

## Problem Analysis

Two current scenarios both fail:

1. **Hide popover after drag starts**: Doesn't work first time it enters WindowLeftTree, but works after moving out and back again
2. **Don't hide popover**: Get drag_enter but never get drag_motion or anything else

The symptoms suggest:

- When hidden immediately, the drag operation isn't fully initialized when first entering WindowLeftTree
- When kept visible, drag_enter fires but drag_motion events don't reach WindowLeftTree's DropTargetAsync

## Solution Approach

Need to investigate and fix the root cause. Possible approaches:

1. Make popover content non-sensitive during drag (allows events to pass through while keeping visible)
2. Use delayed hide with proper timing (allows drag to initialize before hiding)
3. Some other mechanism to ensure drag events reach WindowLeftTree

PopoverAddObject should not accept any drops - only WindowLeftTree accepts drops.

## Implementation Details

### Investigation needed:

- Check if popover or its children are capturing drag events
- Determine why drag_motion doesn't fire when popover is visible
- Determine why first entry fails when popover is hidden immediately

### File: `src/Builder4/PopoverAddObject.bjs`

Potential fixes to try:

1. In `drag_begin` handler: Make content non-sensitive or use delayed hide
2. Ensure no event controllers on popover that would capture drag events
3. Test different timing for hiding popover

## Testing

- Drag from PopoverAddObject to WindowLeftTree should work on first attempt
- WindowLeftTree should receive all drag events (drag_enter, drag_motion, drop)
- Both scenarios (hide immediately vs keep visible) should work

### To-dos

- [ ] Add state variable to PopoverAddObject.bjs to track when drag is active
- [ ] Modify drag_begin handler to make popover transparent to drag events while keeping it visible
- [ ] Modify drag_end handler to restore normal event handling and ensure proper cleanup
- [ ] Test that drag from PopoverAddObject to WindowLeftTree works on first attempt