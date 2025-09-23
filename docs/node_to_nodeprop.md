# Node to NodeProp Refactoring Specification

## Overview

This document outlines the refactoring plan to use the existing `children` array to manage both child nodes and properties, while keeping `propstore` for UI list widgets. Properties will be identified by having a non-empty `prop_name` field.

## Current Architecture

### Current Structure
- **NodeBase**: Abstract base class with `children` array and `prop_name` field
- **Node**: Extends NodeBase, has `propstore` (ListStore<NodeProp>) for UI widgets
- **NodeProp**: Extends NodeBase, represents individual properties
- **NodePropType**: Enum distinguishing between OBJECT, PROP, LISTENER, etc.

### Current Property Management
- Properties are stored in `Node.propstore` (GLib.ListStore<NodeProp>)
- Properties are accessed via `Node.props` and `Node.listeners` computed properties
- Properties are added/removed via `add_prop()`, `remove_prop()`, `has_prop_key()`
- Properties are sorted via `sortProps()` method

## Target Architecture

### New Structure
- **NodeBase**: Unchanged - still has `children` array and `prop_name` field
- **Node**: Extends NodeBase, uses `children` array for both child nodes and properties
- **NodeProp**: Extends NodeBase, properties identified by non-empty `prop_name`
- **NodePropType**: Unchanged

### New Property Management
- Properties will be children with `prop_name` set (non-empty string)
- Regular child nodes will have empty `prop_name`
- Properties accessed by filtering `children` array based on `prop_name`
- **propstore will be kept** for UI list widgets (already designed to handle this change)
- **props/listeners computed properties** - evaluate if still needed or replace with generic methods
- Property validation: prevent duplicate names unless property name ends with "[]"

## Changes Required

### 1. XNS and NTYPE Node Removal

#### Current State
- `xns` and `ntype` are currently stored as separate properties in the `props` HashMap
- `fqn()` method combines `xns` + "." + `xtype` to create fully qualified names
- These properties are used throughout the codebase for namespace and type identification

#### Target State
- Remove `xns` and `ntype` as separate property nodes
- Use `prop_type` field to store the combined value: `xns + '.' + xtype`
- Add backward compatibility methods `xns()` and `xtype()` to Node class
- Update `fqn()` method to use the new `prop_type` value directly

#### Implementation Details
```vala
// New prop_type usage
protected string prop_type { get; set; default = ""; } // Now stores "xns.xtype"

// Backward compatibility methods
public string xns() {
    if (!this.hasXnsType()) return "";
    var parts = this.prop_type.split(".");
    if (parts.length <= 1) return "";
    // Most efficient: resize in place to remove last element
    parts.resize(parts.length - 1);
    return string.joinv(".", parts);
}

public string xtype() {
    if (!this.hasXnsType()) return "";
    var parts = this.prop_type.split(".");
    if (parts.length == 0) return "";
    return parts[parts.length - 1];
}

// Updated methods
public bool hasXnsType() {
    return this.prop_type != null && this.prop_type != "" && this.prop_type.contains(".");
}

public string fqn() {
    if (!this.hasXnsType()) return "";
    return this.prop_type; 
}

public void setFqn(string name) {
    this.prop_type = name;
}

// Updated get() method for backward compatibility
public new string get(string key) {
    if (key == "xns") return this.xns();
    if (key == "xtype") return this.xtype();
    var v = this.props.get(key);
    return v == null ? "" : v.val;
}

// Updated has() method for backward compatibility
public bool has(string key) {
    if (key == "xns" || key == "xtype") return this.hasXnsType();
    return this.props.has_key(key);
}
```

### 2. Node Class Changes

#### Properties to Keep
```vala
// Keep propstore for UI list widgets - already designed to handle this change
public GLib.ListStore propstore { get; set; default = new GLib.ListStore(typeof(NodeProp)); }
```

#### Properties to Evaluate for Removal
```vala
// Evaluate if these computed properties are still needed or should be replaced with generic methods
int props_updated_count = -1;
Gee.HashMap<string,NodeProp> props_cache;
int listeners_updated_count = -1;
Gee.HashMap<string,NodeProp> listeners_cache;
```

#### Methods to Remove
```vala
// Remove these methods from Node class
public void dupeProps()
public void remove_prop(NodeProp prop)
public bool has_prop_key(NodeProp prop)
public void add_prop(NodeProp prop)
private void sortProps()
public int propstore_find(NodeProp child)  // Remove from NodeBase
```

#### Methods to Evaluate
```vala
// Evaluate if these computed properties are still needed for rendering
// Consider replacing with more generic methods
public Gee.HashMap<string,NodeProp> props { get; }
public Gee.HashMap<string,NodeProp> listeners { get; }
```

#### Methods to Modify
```vala
// Modify these methods to work with children array
public Gee.HashMap<string,NodeProp> props {
    owned get {
        // Filter children where prop_name is not empty and ptype != LISTENER
        // Cache result based on updated_count
    }
}

public Gee.HashMap<string,NodeProp> listeners {
    owned get {
        // Filter children where prop_name is not empty and ptype == LISTENER
        // Cache result based on updated_count
    }
}

public NodeProp? find_prop_by_name(string name) {
    // Search through children with non-empty prop_name
}

public Gee.ArrayList<Node> readObjects() {
    // Filter children where node_type == NodePropType.OBJECT
    // (this method already exists and works correctly)
}
```

#### Methods to Add
```vala
// Add these new methods to Node class
public void add_property(NodeProp prop) {
    // Add property as child with prop_name set
    // Validate: prevent duplicate names unless property name ends with "[]"
    // Set parent reference
    // Update updated_count
    // Sort children
    // Update propstore for UI widgets
}

public void remove_property(NodeProp prop) {
    // Remove property from children array
    // Update updated_count
    // Update propstore for UI widgets
}

public bool has_property_key(NodeProp prop) {
    // Check if property exists in children array
    // Validate: prevent duplicate names unless property name ends with "[]"
}

public Gee.ArrayList<NodeProp> get_properties() {
    // Return all children with non-empty prop_name
}

public Gee.ArrayList<NodeProp> get_listeners() {
    // Return all children with non-empty prop_name and ptype == LISTENER
}

public Gee.ArrayList<NodeProp> get_non_listener_properties() {
    // Return all children with non-empty prop_name and ptype != LISTENER
}

// Generic method to replace props/listeners if needed
public Gee.ArrayList<NodeProp> get_properties_by_type(NodePropType? filter_type = null) {
    // Return all children with non-empty prop_name
    // Optionally filter by NodePropType
}
```

### 2. NodeBase Class Changes

#### Methods to Remove
```vala
// Remove from NodeBase class
public int propstore_find(NodeProp child)
```

#### Methods to Modify
```vala
// Modify setStores method
public void setStores(bool recursive = true) {
    if (this.node_type == NodePropType.OBJECT && this.parent != null) {
        this.parent.childstore.append(this as Node);
    }
    // Properties are now children, but propstore is kept for UI widgets
    // Recursively set stores for all children (if requested)
    if (recursive) {
        foreach(var c in this.children) {
            c.setStores();
        }
    }
}

// Modify removeFromStore method
public void removeFromStore(bool recursive = true) {
    // First, recursively remove all children from their stores (if requested)
    if (recursive) {
        foreach(var c in this.children) {
            c.removeFromStore();
        }
    }
    
    // Then remove this node from its parent's stores
    if (this.parent != null) {
        if (this.node_type == NodePropType.OBJECT) {
            var pos = this.parent.childstore_find(this);
            if (pos != -1) {
                this.parent.childstore.remove(pos);
            }
        }
        // Properties are now children, but propstore is kept for UI widgets
    }
}
```

### 3. Serialization Changes
=
none

### 4. Legacy File Reading Changes

#### Replace '* prop' with prop_name
```vala
// Update legacy file reading to convert '* prop' to prop_name
// Remove nodes that have '* prop'
// This should be done during file loading/parsing
```

#### New UI Element for Property Editing
```vala
// Create new UI element for editing properties on child objects
// This will allow setting prop_name for children that are properties
// Should integrate with existing property editing workflow
```

### 5. Action System Integration

#### Property Actions
```vala
// All property modifications should go through Actions for undo/redo support
// Create new Action classes:
// - AddPropertyAction
// - RemovePropertyAction  
// - ModifyPropertyAction
// - SetPropertyNameAction

// UI should use Actions instead of direct property manipulation
// This ensures all changes can be undone/redone
```

### 6. UI Component Changes

#### Builder4 Components
UI components should continue using `propstore` for list widgets, but property operations should use Actions:

- **WindowLeftProps.vala**: Continue using propstore for list binding
- **PopoverAddProp.vala**: Use Actions for property addition
- **PopoverProperty.vala**: Use Actions for property editing
- **CodeInfo.vala**: Use Actions for property display logic

#### Key Changes in UI Components
```vala
// Property operations should use Actions
// OLD: node.add_prop(prop)
// NEW: ActionManager.execute(new AddPropertyAction(node, prop))

// OLD: node.remove_prop(prop)
// NEW: ActionManager.execute(new RemovePropertyAction(node, prop))

// Property validation in Actions
// Check for duplicate names unless property name ends with "[]"
// Prevent invalid property additions
```

### 7. Code Generation Changes

#### NodeToVala.vala
```vala
// Update property iteration
// OLD: foreach(var prop in this.node.props.values)
// NEW: foreach(var prop in this.node.get_non_listener_properties())

// Update property access patterns
// OLD: this.node.props.get(prop.name)
// NEW: this.node.find_prop_by_name(prop.name)

// XNS/NTYPE changes - no changes needed as xns() and xtype() methods provide backward compatibility
```

#### NodeToJs.vala
```vala
// Update property checking
// OLD: if (!pl.props.has_key("* prop"))
// NEW: if (pl.find_prop_by_name("* prop") == null)

// XNS/NTYPE changes - update to use new methods
// OLD: if (this.out_props.has_key("xns"))
// NEW: if (this.node.hasXnsType())
// OLD: var v = this.out_props.get("xns");
// NEW: var xns_val = this.node.xns();
// NEW: var xtype_val = this.node.xtype();
```

#### NodeToGtk.vala
```vala
// Update property iteration
// OLD: foreach(var prop in this.node.props.values)
// NEW: foreach(var prop in this.node.get_non_listener_properties())

// XNS/NTYPE changes - no changes needed as xns() and xtype() methods provide backward compatibility
```

#### NodeWriter.vala
```vala
// XNS/NTYPE changes - update to use new methods
// OLD: return item.get("xns") + ".";
// NEW: return item.xns() + ".";
```

#### JsRender.vala
```vala
// XNS/NTYPE changes - update to use new methods
// OLD: return ar.get("xns") + "." + ar.get("xtype");
// NEW: return ar.fqn();
```

## Migration Strategy

### Phase 1: Add New Methods and Actions
1. Add new property access methods to Node class
2. Implement children-based property filtering
3. Use ChangeProp Action class for property operations
4. Add property validation (duplicate name checking)
5. **Add xns() and xtype() backward compatibility methods to Node class**
6. **Update fqn(), hasXnsType(), get(), and has() methods to use prop_type**

### Phase 2: XNS/NTYPE Migration
1. **Update code generation classes to use new xns() and xtype() methods**
2. **Test backward compatibility with existing code**
3. **Update any remaining direct references to xns/xtype properties**
4. **Remove xns and ntype property creation from setFqn() method**

### Phase 3: Update Legacy File Reading
1. Update file loading to convert '* prop' to prop_name
2. Remove nodes with '* prop' and create proper NodeProp children
3. Test file loading with existing projects

### Phase 4: Create New UI Elements
1. Create UI element for editing properties on child objects
2. Integrate with existing property editing workflow
3. Test property editing functionality

### Phase 5: Update UI Components to Use Actions
1. Update Builder4 components to use Actions for property operations
2. Keep propstore for list widgets (already designed for this)
3. Test property display and editing functionality
4. Ensure UI responsiveness is maintained

### Phase 6: Evaluate and Update Computed Properties
1. Analyze usage of props/listeners computed properties
2. Determine if they're still needed or should be replaced with generic methods
3. Update code generation classes accordingly
4. Test generated code output

### Phase 7: Remove Legacy Code
1. Remove unused methods (dupeProps, old add_prop, etc.)
2. Remove propstore_find from NodeBase (propstore kept for UI widgets)
3. Clean up serialization code
4. Remove backward compatibility wrappers if no longer needed

### Phase 8: Testing and Validation
1. Comprehensive testing of all functionality
2. Performance testing with large projects
3. Memory usage validation
4. UI responsiveness testing
5. Undo/redo functionality testing

## Benefits

### Simplified Architecture
- Single source of truth for all children (nodes and properties)
- propstore kept for UI widgets (already designed for this change)
- Clear separation between data storage (children) and UI display (propstore)
- **Simplified namespace/type management with single prop_type field**
- **Elimination of separate xns/ntype property nodes**

### Improved Maintainability
- Simpler data management (children for data, propstore for UI)
- Simpler serialization/deserialization
- More consistent API
- Better separation of concerns (UI vs data)
- **Reduced complexity in namespace/type handling**
- **Backward compatibility maintained through xns()/xtype() methods**

### Better Performance
- More efficient property storage (children for data, propstore for UI)
- Faster property access through direct children iteration
- propstore only used where needed (UI widgets)
- **Reduced memory usage by eliminating separate xns/ntype property nodes**
- **Faster fqn() computation using direct prop_type access**

### Enhanced User Experience
- Full undo/redo support through Actions
- Property validation prevents invalid states
- Better property editing workflow

## Risks and Considerations

### Breaking Changes
- Code accessing `propstore` directly for data operations will break
- UI components need updates to use Actions
- Serialization format changes
- Legacy file format changes ('* prop' → prop_name)

### Performance Impact
- Property filtering may be slower than direct propstore access
- Need to implement efficient caching
- Large numbers of properties may impact performance
- propstore maintenance overhead (keeping it in sync with children)

### Testing Requirements
- Comprehensive testing of all property operations
- UI component testing with Actions
- Code generation testing
- Performance testing
- Undo/redo functionality testing
- Legacy file loading testing

### Implementation Complexity
- Action system integration adds complexity
- Property validation logic needs careful implementation
- UI element for property editing needs design
- Legacy file migration needs thorough testing

## Implementation Timeline

1. **Week 1-2**: Phase 1 - Add new methods and Actions (including xns/xtype methods)
2. **Week 3**: Phase 2 - XNS/NTYPE Migration
3. **Week 4**: Phase 3 - Update legacy file reading
4. **Week 5**: Phase 4 - Create new UI elements
5. **Week 6-7**: Phase 5 - Update UI components to use Actions
6. **Week 8**: Phase 6 - Evaluate and update computed properties
7. **Week 9**: Phase 7 - Remove legacy code
8. **Week 10-11**: Phase 8 - Testing and validation

## Conclusion

This refactoring will significantly simplify the Node architecture by using the children array for both child nodes and properties, while keeping propstore for UI widgets. The integration with the Action system will provide full undo/redo support and better property validation. Additionally, the elimination of separate xns/ntype property nodes in favor of a single prop_type field will further simplify the architecture while maintaining backward compatibility.

Key success factors:
- Careful implementation of property validation (duplicate name checking)
- Proper Action system integration for all property operations
- Thorough testing of legacy file migration ('* prop' → prop_name)
- Maintaining propstore for UI widgets while using children for data operations
- **Proper implementation of xns()/xtype() backward compatibility methods**
- **Thorough testing of prop_type-based namespace/type management**
- Comprehensive testing of all affected components

The benefits in terms of maintainability, performance, architectural consistency, and enhanced user experience make this a worthwhile investment. The xns/ntype consolidation will provide additional benefits in terms of code simplicity and performance.
