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

def count_brackets_ignoring_strings(line):
    """
    Count brackets and parentheses in a line, ignoring those inside string literals.
    Returns tuple: (open_braces, close_braces, open_parens, close_parens)
    """
    open_braces = 0
    close_braces = 0
    open_parens = 0
    close_parens = 0
    
    i = 0
    in_string = False
    escape_next = False
    
    while i < len(line):
        char = line[i]
        
        if escape_next:
            escape_next = False
            i += 1
            continue
        
        if char == '\\':
            escape_next = True
            i += 1
            continue
        
        if char == '"' and not escape_next:
            in_string = not in_string
            i += 1
            continue
        
        if not in_string:
            if char == '{':
                open_braces += 1
            elif char == '}':
                close_braces += 1
            elif char == '(':
                open_parens += 1
            elif char == ')':
                close_parens += 1
        
        i += 1
    
    return open_braces, close_braces, open_parens, close_parens

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
    
    # Second pass: Calculate indentation levels (including switch/case logic)
    indent_levels = []  # Store calculated indentation for each line
    indent_level = 0
    switch_stack = []  # Track switch statement nesting levels
    in_case_body = False  # Track if we're in a case body
    
    for i, line in enumerate(converted_lines):
        stripped = line.strip()
        
        # Skip empty lines
        if not stripped:
            indent_levels.append(0)  # Empty lines have no indentation
            continue
        
        # Count indentation changes for this line (ignoring strings)
        open_braces, close_braces, open_parens, close_parens = count_brackets_ignoring_strings(stripped)
        indent_change = open_braces + open_parens - close_braces - close_parens
        
        # Calculate base indentation from brace counting
        base_indent = indent_level
        
        # Handle switch statement detection
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
        
        # Store the calculated indentation level
        indent_levels.append(display_indent)
        
        # Update indent level for next line
        indent_level += indent_change
        indent_level = max(0, indent_level)
    
    # Third pass: Apply the calculated indentation
    final_lines = []
    for i, line in enumerate(converted_lines):
        stripped = line.strip()
        
        # Skip empty lines
        if not stripped:
            final_lines.append('\n')
            continue
        
        # Apply the pre-calculated indentation
        display_indent = indent_levels[i]
        new_line = '\t' * display_indent + stripped + '\n'
        final_lines.append(new_line)
    
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
