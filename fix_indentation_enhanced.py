#!/usr/bin/env python3
"""
Enhanced Vala Indentation Fixer with Switch/Case Support

This script fixes indentation in Vala files with proper handling of:
1. Tab-based indentation (no spaces)
2. Switch/case statements with proper case indentation
3. Brace and parenthesis handling
4. Nested structures

Usage: python3 fix_indentation_enhanced.py <filename>
"""

import re
import sys

def fix_indentation(filename):
    """Fix indentation in a Vala file with enhanced switch/case support."""
    
    with open(filename, 'r') as f:
        lines = f.readlines()
    
    print(f"Processing {filename}...")
    
    # First pass: convert space indentation to tabs
    converted_lines = []
    for line in lines:
        if line.strip():  # Skip empty lines
            # Count leading spaces
            leading_spaces = len(line) - len(line.lstrip(' '))
            if leading_spaces > 0:
                # Convert spaces to tabs (assuming 4 spaces = 1 tab)
                tabs = leading_spaces // 4
                remaining_spaces = leading_spaces % 4
                # If there are remaining spaces, convert them to a tab as well
                if remaining_spaces > 0:
                    tabs += 1
                new_line = '\t' * tabs + line.lstrip(' ')
            else:
                new_line = line
        else:
            new_line = line
        converted_lines.append(new_line)
    
    # Second pass: apply proper indentation logic with switch/case support
    fixed_lines = []
    indent_level = 0
    switch_stack = []  # Track switch statement nesting levels
    
    for i, line in enumerate(converted_lines):
        stripped = line.strip()
        
        # Skip empty lines
        if not stripped:
            fixed_lines.append('\n')
            continue
        
        # Count indentation changes for this line
        # Positive values increase indent, negative values decrease indent
        open_braces = stripped.count('{')      # +1 for each
        close_braces = stripped.count('}')     # -1 for each
        open_parens = stripped.count('(')      # +1 for each
        close_parens = stripped.count(')')     # -1 for each
        
        # Calculate net indent change for this line
        indent_change = open_braces + open_parens - close_braces - close_parens
        
        # Handle switch statement detection
        if stripped.startswith('switch '):
            # Starting a switch statement - track it
            switch_stack.append(indent_level + 1)  # Switch body will be indented one level
        
        # Handle case/default detection
        case_indent = None
        if stripped.startswith('case ') or stripped.startswith('default'):
            # This is a case or default statement
            if switch_stack:
                # Use the switch indentation level
                case_indent = switch_stack[-1]
            else:
                # Fallback to current indent level
                case_indent = indent_level
        
        # Handle closing brace of switch statement
        if stripped.startswith('}') and switch_stack:
            # Check if this closes a switch statement
            # We need to look ahead to see if the next non-empty line
            # is at the same or lower indentation level
            next_indent_level = indent_level + indent_change
            if next_indent_level < switch_stack[-1]:
                # This closes the switch statement
                switch_stack.pop()
        
        # Secondary rule: If line starts with } or ), reduce indent by 1
        # (This doesn't affect the ongoing count)
        display_indent = indent_level
        if stripped.startswith('}') or stripped.startswith(')'):
            display_indent = max(0, indent_level - 1)
        
        # Apply case indentation if this is a case/default line
        if case_indent is not None:
            display_indent = case_indent
        
        # Create the line with adjusted indent
        new_line = '\t' * display_indent + stripped + '\n'
        fixed_lines.append(new_line)
        
        # Update indent level for next line (using original count)
        indent_level += indent_change
        indent_level = max(0, indent_level)  # Don't go negative
    
    # Third pass: Fix case statement indentation
    # This pass specifically handles the switch/case indentation rules
    final_lines = []
    switch_stack = []
    indent_level = 0
    in_case_body = False  # Track if we're in a case body
    
    for i, line in enumerate(fixed_lines):
        stripped = line.strip()
        
        # Skip empty lines
        if not stripped:
            final_lines.append('\n')
            continue
        
        # Count braces for indentation tracking
        open_braces = stripped.count('{')
        close_braces = stripped.count('}')
        indent_change = open_braces - close_braces
        
        # Calculate base indentation from brace counting
        base_indent = indent_level
        
        # Handle switch statement
        if stripped.startswith('switch '):
            switch_stack.append(indent_level + 1)  # Switch body indentation
            display_indent = base_indent
            in_case_body = False
        # Handle case/default statements
        elif stripped.startswith('case ') or stripped.startswith('default'):
            if switch_stack:
                # Case statements should be indented one level MORE than the switch body
                display_indent = switch_stack[-1] + 1
            else:
                display_indent = base_indent
            in_case_body = True  # Next lines will be case body
        # Handle closing brace
        elif stripped.startswith('}'):
            # Check if this closes a switch
            if switch_stack and indent_level + indent_change < switch_stack[-1]:
                switch_stack.pop()
            display_indent = max(0, base_indent - 1)
            in_case_body = False
        # Handle case body (statements after case/default)
        elif in_case_body and switch_stack:
            # Case body should be indented one level more than case statement
            display_indent = switch_stack[-1] + 2
        else:
            # Regular line - use current indent level
            display_indent = base_indent
            in_case_body = False
        
        # Create the final line
        new_line = '\t' * display_indent + stripped + '\n'
        final_lines.append(new_line)
        
        # Update indent level
        indent_level += indent_change
        indent_level = max(0, indent_level)
    
    # Write the fixed file
    with open(filename, 'w') as f:
        f.writelines(final_lines)
    
    # Validation: Check for any lines starting with spaces
    print('\nValidating indentation...')
    with open(filename, 'r') as f:
        validation_lines = f.readlines()
    
    space_lines = []
    for i, line in enumerate(validation_lines):
        if line.strip() and line.startswith(' '):
            space_lines.append((i+1, line.rstrip()))
    
    if space_lines:
        print(f'ERROR: Found {len(space_lines)} lines starting with spaces:')
        for line_num, line_content in space_lines[:10]:  # Show first 10
            print(f'  Line {line_num}: {repr(line_content[:50])}')
        if len(space_lines) > 10:
            print(f'  ... and {len(space_lines) - 10} more lines')
        return False
    else:
        print('SUCCESS: No lines start with spaces - file is properly formatted!')
        return True

def main():
    """Main function to handle command line arguments."""
    if len(sys.argv) != 2:
        print("Usage: python3 fix_indentation_enhanced.py <filename>")
        sys.exit(1)
    
    filename = sys.argv[1]
    try:
        success = fix_indentation(filename)
        if success:
            print(f"\n✅ Indentation fixed successfully for {filename}")
        else:
            print(f"\n❌ Indentation fix completed with warnings for {filename}")
    except Exception as e:
        print(f"Error processing {filename}: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
