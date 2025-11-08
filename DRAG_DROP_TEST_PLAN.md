# Drag-and-Drop Testing Plan

**Current Working State**: Tagged as `working-minimal-splitview`
- Minimal startup code in `Application.activate()`
- HeaderBar (minimal)
- SplitView structure (Adw.OverlaySplitView → VBox → MainPane → LeftPane → EditPane)
- Tree (WindowLeftTree) added to `win.tree.el`
- No other components initialized

**Goal**: Identify which components/initialization steps break drag-and-drop functionality.

---

## Testing Steps

### Step 1: Statusbar
**Action**: Enable statusbar initialization in `WindowState.init()`
- Uncomment statusbar visibility code
- Test drag-and-drop
- **Expected**: Should work (statusbar is separate from tree)

---

### Step 2: Application Startup Code
**Action**: Add back removed startup code in `Application.activate()`
- Add `BuilderApplication.settings = new Settings();`
- Add `ValaSymbolGirBuilder` creation
- Add `WindowManager.load()` check
- Test drag-and-drop
- **Expected**: Should work (these are background services)

---

### Step 3: Dialogs/Popovers (File Dialog)
**Action**: Enable file dialog initialization
- Uncomment `popover_files = new DialogFiles();` in `WindowState.init()`
- Test drag-and-drop
- **Expected**: Should work (popover is separate widget)

---

### Step 4: Template Select Dialog
**Action**: Enable template select dialog
- Uncomment `template_select = new DialogTemplateSelect();` in `WindowState.init()`
- Test drag-and-drop
- **Expected**: Should work (dialog is separate widget)

---

### Step 5: File Details Dialog
**Action**: Enable file details dialog
- Uncomment `fileDetailsInit();` in `WindowState.init()`
- Test drag-and-drop
- **Expected**: Should work (dialog is separate widget)

---

### Step 6: Compile Results
**Action**: Enable compile results panel
- Uncomment `compile_results = new Xcls_ValaCompileResults();` in `WindowState.init()`
- Uncomment signal connection `BuilderApplication.valasource.compile_output.connect(...)`
- Test drag-and-drop
- **Expected**: May fail (compile results might add widgets that interfere)

---

### Step 7: Code Editor
**Action**: Enable code editor
- Uncomment `codeEditInit();` in `WindowState.init()`
- Test drag-and-drop
- **Expected**: May fail (code editor adds widgets to splitview)

---

### Step 8: Preview Views (GtkView)
**Action**: Enable GtkView preview
- Uncomment `gtkViewInit();` in `WindowState.init()`
- Test drag-and-drop
- **Expected**: May fail (adds widgets to splitview)

---

### Step 9: Preview Views (WebkitView)
**Action**: Enable WebkitView preview
- Uncomment `webkitViewInit();` in `WindowState.init()`
- Test drag-and-drop
- **Expected**: May fail (adds widgets to splitview)

---

### Step 10: Properties Panel (LeftProps) - **KNOWN ISSUE**
**Action**: Enable properties panel
- Uncomment `propsListInit();` in `WindowState.init()`
- Test drag-and-drop
- **Expected**: **WILL FAIL** - This is the known problematic component
- **Note**: This was previously identified as breaking drag-and-drop

---

### Step 11: Tree Signal Handlers
**Action**: Enable tree signal handlers
- Uncomment `before_node_change` signal handler in `leftTreeInit()`
- Uncomment `node_selected` signal handlers in `leftTreeInit()`
- Uncomment `changed` signal handler in `leftTreeInit()`
- Test drag-and-drop
- **Expected**: Should work (signal handlers shouldn't affect drag/drop)

---

### Step 12: Sidebar
**Action**: Enable sidebar in splitview
- Check if sidebar is hidden/disabled in `MainWindow.vala` splitview initialization
- Enable sidebar if it's disabled
- Test drag-and-drop
- **Expected**: May fail (sidebar adds widgets to splitview)

---

### Step 13: HeaderBar Full Implementation
**Action**: Restore full headerbar with buttons and functionality
- Restore headerbar button creation and signal handlers
- Test drag-and-drop
- **Expected**: May fail (headerbar buttons might interfere)

---

### Step 14: WindowManager.load() Restore
**Action**: Restore window state loading
- Uncomment `WindowManager.load()` check in `Application.activate()`
- Test drag-and-drop
- **Expected**: Should work (window state loading shouldn't affect drag/drop)

---

### Step 15: initChildren() Call
**Action**: Restore `initChildren()` call
- Change `Application.activate()` to call `w.initChildren()` instead of direct `windowstate` creation
- Test drag-and-drop
- **Expected**: Should work (just different initialization order)

---

## Testing Protocol

1. **After each step**:
   - Compile the application
   - Test drag-and-drop functionality
   - If drag-and-drop **WORKS**: Tag as `working-step-N` and continue to next step
   - If drag-and-drop **FAILS**: Tag as `broken-step-N`, document the failure, and roll back

2. **Documentation**:
   - Record which step breaks drag-and-drop
   - Note any error messages or symptoms
   - Identify the specific component/widget that causes the issue

3. **Isolation**:
   - If a step fails, try to isolate the specific part of that step
   - For example, if Step 7 (Code Editor) fails, try enabling only parts of it

---

## Known Issues

- **Step 10 (Properties Panel)**: Previously identified as breaking drag-and-drop
- **SplitView Structure**: The complex nested structure (SplitView → VBox → MainPane → LeftPane → EditPane) is currently working, so the issue is likely with additional widgets added to this structure

---

## Notes

- The current working state has the splitview structure but minimal components
- The tree is added to `win.tree.el` which is inside the `editpane`
- All signal handlers are disabled
- Most UI components are disabled/hidden

