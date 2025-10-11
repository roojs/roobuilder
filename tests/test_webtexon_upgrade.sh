#!/bin/bash -x

# Test BJS file upgrade for web.Texon/Pman/Shipping project
# Usage: ./test_webtexon_upgrade.sh [bjs_file_path]
# If no file specified, tests Pman.Dialog.Material.bjs by default

# Default file to test
DEFAULT_FILE="Pman.Dialog.Material.bjs"
BJS_FILE="${1:-$DEFAULT_FILE}"

# Project directory
PROJECT_DIR="/home/alan/gitlive/web.Texon/Pman/Shipping"
FILENAME=$(basename "$BJS_FILE")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$SCRIPT_DIR/results"
mkdir -p "$TEST_DIR"

echo "=== Web.Texon BJS File Upgrade Test ==="
echo "Testing: $BJS_FILE"
echo "Project: $PROJECT_DIR"
echo "Date: $(date)"
echo ""

# Check if file exists
if [[ ! -f "$PROJECT_DIR/$BJS_FILE" ]]; then
    echo "ERROR: File not found: $PROJECT_DIR/$BJS_FILE"
    echo ""
    echo "Available BJS files in project:"
    echo "==============================="
    find "$PROJECT_DIR" -name "*.bjs" -type f | head -20 | sed 's|.*/||' | sort
    echo "... (showing first 20 files)"
    exit 1
fi

# Check file size
FILE_SIZE=$(stat -c%s "$PROJECT_DIR/$BJS_FILE" 2>/dev/null || echo "0")
echo "File size: $FILE_SIZE bytes"

# Check if file has content
if [[ "$FILE_SIZE" -eq 0 ]]; then
    echo "ERROR: Empty file"
    exit 1
fi

# Show first few lines of the file
echo ""
echo "First 10 lines of the file:"
echo "----------------------------"
head -n 10 "$PROJECT_DIR/$BJS_FILE"
echo ""

# Check for version information
echo "=== Version Check ==="
if grep -q "bjs_version" "$PROJECT_DIR/$BJS_FILE"; then
    VERSION=$(grep "bjs_version" "$PROJECT_DIR/$BJS_FILE" | head -n 1 | sed 's/.*bjs_version.*: *\([0-9]*\).*/\1/')
    echo "Version found in file: $VERSION"
else
    echo "No version information found in file (old format)"
fi

# Check if roobuilder build exists
if [[ ! -f "../build/roobuilder" ]]; then
    echo "ERROR: Local build not found at ../build/roobuilder"
    echo "Please build the project first with: ninja -C build"
    exit 1
fi

# Test upgrade command
echo ""
echo "=== Testing BJS Upgrade ==="
echo "Command: ../build/roobuilder --project $PROJECT_DIR --test-bjs-upgrade $BJS_FILE"
echo ""

OUTPUT_FILE="$TEST_DIR/${FILENAME%.bjs}.bjs3"
ERROR_FILE="$TEST_DIR/${FILENAME%.bjs}_upgrade_error.log"

# Run upgrade
echo "Running upgrade..."
echo "Command: ../build/roobuilder --project \"$PROJECT_DIR\" --test-bjs-upgrade \"$BJS_FILE\"" > "$ERROR_FILE"
if ../build/roobuilder --project "$PROJECT_DIR" --test-bjs-upgrade "$BJS_FILE" > "$OUTPUT_FILE" 2>> "$ERROR_FILE"; then
    echo "SUCCESS: Upgrade completed"
    
    if [[ -f "$OUTPUT_FILE" && -s "$OUTPUT_FILE" ]]; then
        echo "Output file size: $(stat -c%s "$OUTPUT_FILE") bytes"
        echo ""
        echo "First 30 lines of upgraded JSON:"
        echo "---------------------------------------"
        head -n 30 "$OUTPUT_FILE"
        echo ""
        
        # Check if output looks like valid JSON
        if head -n 1 "$OUTPUT_FILE" | grep -q "{"; then
            echo "✓ Valid JSON output generated"
        else
            echo "⚠ Output may not be valid JSON"
        fi
        
        # Check for bjs_version in output
        if grep -q "bjs_version" "$OUTPUT_FILE"; then
            NEW_VERSION=$(grep "bjs_version" "$OUTPUT_FILE" | head -n 1 | sed 's/.*bjs_version.*: *\([0-9]*\).*/\1/')
            echo "✓ Upgraded to version: $NEW_VERSION"
        fi
        
        # Check for nodeprop format (new format indicator)
        if grep -q "nodeprop" "$OUTPUT_FILE"; then
            echo "✓ Contains nodeprop format (new format)"
        fi
        
    else
        echo "ERROR: No output generated"
    fi
else
    echo "ERROR: Upgrade failed (exit code: $?)"
    
    if [[ -f "$ERROR_FILE" && -s "$ERROR_FILE" ]]; then
        echo ""
        echo "Error details:"
        echo "--------------"
        cat "$ERROR_FILE"
    fi
fi

# Compare with original file
echo ""
echo "=== Comparison with Original BJS File ==="
echo "Comparing with: $PROJECT_DIR/$BJS_FILE"

if [[ -f "$OUTPUT_FILE" && -s "$OUTPUT_FILE" ]]; then
    ORIGINAL_SIZE=$(stat -c%s "$PROJECT_DIR/$BJS_FILE" 2>/dev/null || echo "0")
    NEW_SIZE=$(stat -c%s "$OUTPUT_FILE" 2>/dev/null || echo "0")
    
    echo "Original BJS file size: $ORIGINAL_SIZE bytes"
    echo "Upgraded BJS file size: $NEW_SIZE bytes"
    
    if [[ "$NEW_SIZE" -gt "$ORIGINAL_SIZE" ]]; then
        echo "✓ Upgraded file is larger (as expected for new format)"
    else
        echo "⚠ Upgraded file is same or smaller - check format"
    fi
    
    # Show structure differences
    echo ""
    echo "Structure changes:"
    echo "------------------"
    if grep -q "nodeprop" "$OUTPUT_FILE"; then
        echo "✓ New format detected (contains 'nodeprop')"
    fi
    if grep -q "bjs_version" "$OUTPUT_FILE"; then
        echo "✓ Version field added"
    fi
else
    echo "⚠ Cannot compare - no upgraded output"
fi

echo ""
echo "=== File Information ==="
echo "BJS File: $PROJECT_DIR/$BJS_FILE"
echo "Project Directory: $PROJECT_DIR"
echo "Working Directory: $(pwd)"
echo "Test Directory: $TEST_DIR"

# Check if this is a Tab or Dialog file
if [[ "$BJS_FILE" == *".Tab."* ]]; then
    echo "File Type: Tab component"
elif [[ "$BJS_FILE" == *".Dialog."* ]]; then
    echo "File Type: Dialog component"
else
    echo "File Type: Other component"
fi

# Count total BJS files in project
TOTAL_BJS=$(find "$PROJECT_DIR" -name "*.bjs" -type f | wc -l)
echo "Total BJS files in project: $TOTAL_BJS"

echo ""
echo "=== Test Summary ==="
if [[ -f "$OUTPUT_FILE" && -s "$OUTPUT_FILE" ]]; then
    echo "✓ BJS upgrade successful"
    echo "✓ New format output generated"
    if grep -q "nodeprop" "$OUTPUT_FILE"; then
        echo "✓ Upgraded to new nodeprop format"
    fi
else
    echo "❌ BJS upgrade failed"
fi

echo ""
echo "Test results saved to: $TEST_DIR"
echo "Upgraded BJS3 file: $OUTPUT_FILE"
if [[ -f "$ERROR_FILE" && -s "$ERROR_FILE" ]]; then
    echo "Error log: $ERROR_FILE"
fi

