#!/usr/bin/env python3
"""
Vala Brace Formatting Fixer

This script fixes brace placement in Vala files according to the general brace formatting rules:
1. Method declarations: opening braces on new line
2. Control statements: opening braces on new line
3. Always use braces with control statements

Usage: python3 fix_brace_formatting.py <filename>
"""

import re
import sys

def fix_brace_formatting(filename):
    """Fix brace formatting in a Vala file according to general brace formatting rules."""
    
    with open(filename, 'r') as f:
        lines = f.readlines()
    
    print(f"Processing {filename}...")
    
    fixed_lines = []
    
    for i, line in enumerate(lines):
        stripped = line.strip()
        
        # Skip empty lines
        if not stripped:
            fixed_lines.append(line)
            continue
        
        # Fix method declarations - move opening brace to new line
        # Pattern for method declarations with brace on same line
        method_pattern = r'^(\s*)(.*?)\s*\{$'
        method_match = re.match(method_pattern, stripped)
        
        if method_match:
            # Get original indentation from the line (before stripping)
            original_indent = line[:len(line) - len(line.lstrip())]
            method_sig = method_match.group(2)
            
            # Check if this looks like a method declaration
            # (contains return type and method name, ends with parentheses)
            if re.search(r'\w+\s+\w+\s*\([^)]*\)\s*(throws\s+\w+)?$', method_sig):
                # Add method signature without brace
                fixed_lines.append(f"{original_indent}{method_sig}\n")
                # Add opening brace on new line with same indentation
                fixed_lines.append(f"{original_indent}{{\n")
                continue
        
        # Also check for method declarations that span multiple lines
        # Look ahead to see if next line is just an opening brace
        if i + 1 < len(lines):
            next_line = lines[i + 1].strip()
            if next_line == '{':
                # This is a method declaration followed by opening brace on next line
                # Check if current line looks like a method declaration
                if re.search(r'\w+\s+\w+\s*\([^)]*\)\s*(throws\s+\w+)?$', stripped):
                    # This is already correctly formatted, keep as-is
                    fixed_lines.append(line)
                    continue
        
        # Fix control statements - move opening brace to new line
        control_patterns = [
            r'^\s*if\s*\([^)]*\)\s*\{',
            r'^\s*for\s*\([^)]*\)\s*\{',
            r'^\s*while\s*\([^)]*\)\s*\{',
            r'^\s*switch\s*\([^)]*\)\s*\{',
            r'^\s*catch\s*\([^)]*\)\s*\{',
            r'^\s*try\s*\{',
            r'^\s*else\s*\{',
            r'^\s*else\s+if\s*\([^)]*\)\s*\{'
        ]
        
        brace_moved = False
        for pattern in control_patterns:
            if re.match(pattern, stripped):
                # Control statement with brace on same line
                control_match = re.match(r'^(\s*)(.*?)\s*\{', stripped)
                if control_match:
                    indent = control_match.group(1)
                    control_sig = control_match.group(2)
                    
                    # Add control statement without brace
                    fixed_lines.append(f"{indent}{control_sig}\n")
                    # Add opening brace on new line with same indentation
                    fixed_lines.append(f"{indent}{{\n")
                    brace_moved = True
                    break
        
        if brace_moved:
            continue
        
        # Fix control statements without braces - add braces
        no_brace_patterns = [
            r'^\s*if\s*\([^)]*\)\s*[^{]',
            r'^\s*for\s*\([^)]*\)\s*[^{]',
            r'^\s*while\s*\([^)]*\)\s*[^{]',
            r'^\s*else\s*[^{]',
            r'^\s*else\s+if\s*\([^)]*\)\s*[^{]'
        ]
        
        brace_added = False
        for pattern in no_brace_patterns:
            if re.match(pattern, stripped):
                # Control statement without braces
                control_match = re.match(r'^(\s*)(.*?)\s+(.+)$', stripped)
                if control_match:
                    indent = control_match.group(1)
                    control_sig = control_match.group(2)
                    statement = control_match.group(3)
                    
                    # Add control statement with opening brace
                    fixed_lines.append(f"{indent}{control_sig}\n")
                    # Add opening brace
                    fixed_lines.append(f"{indent}{{\n")
                    # Add statement with extra indentation
                    fixed_lines.append(f"{indent}\t{statement}\n")
                    # Add closing brace
                    fixed_lines.append(f"{indent}}}\n")
                    brace_added = True
                    break
        
        if brace_added:
            continue
        
        # Keep the line as-is if no changes needed
        fixed_lines.append(line)
    
    # Write the fixed file
    with open(filename, 'w') as f:
        f.writelines(fixed_lines)
    
    print(f"✅ Brace formatting fixed successfully for {filename}")

def main():
    """Main function to handle command line arguments."""
    if len(sys.argv) != 2:
        print("Usage: python3 fix_brace_formatting.py <filename>")
        sys.exit(1)
    
    filename = sys.argv[1]
    try:
        fix_brace_formatting(filename)
    except Exception as e:
        print(f"Error processing {filename}: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
