#!/bin/bash -x

# Test BJS file compilation for web.Texon/Pman/Shipping project
# Usage: ./test_webtexon_bjs.sh [bjs_file_path]
# If no file specified, tests Pman.Tab.ShippingOrders.bjs by default

# Default file to test
DEFAULT_FILE="Pman.Tab.ShippingOrders.bjs"
BJS_FILE="${1:-$DEFAULT_FILE}"

# Project directory
PROJECT_DIR="/home/alan/gitlive/web.Texon/Pman/Shipping"
FILENAME=$(basename "$BJS_FILE")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$SCRIPT_DIR/results"
mkdir -p "$TEST_DIR"

echo "=== Web.Texon BJS File Test ==="
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
    echo "No version information found in file"
fi

# Check if roobuilder build exists
if [[ ! -f "../build/roobuilder" ]]; then
    echo "ERROR: Local build not found at ../build/roobuilder"
    echo "Please build the project first with: ninja -C build"
    exit 1
fi

# Test compilation command
echo ""
echo "=== Testing BJS Compilation ==="
echo "Command: ../build/roobuilder --project $PROJECT_DIR --test-bjs-compile $BJS_FILE"
echo ""

OUTPUT_FILE="$TEST_DIR/${FILENAME%.bjs}_generated.js"
ERROR_FILE="$TEST_DIR/${FILENAME%.bjs}_error.log"

# Run compilation
echo "Running compilation..."
echo "Command: ../build/roobuilder --project \"$PROJECT_DIR\" --test-bjs-compile \"$BJS_FILE\"" > "$ERROR_FILE"
if ../build/roobuilder --project "$PROJECT_DIR" --test-bjs-compile "$BJS_FILE" > "$OUTPUT_FILE" 2>> "$ERROR_FILE"; then
    echo "SUCCESS: Compilation completed"
    
    if [[ -f "$OUTPUT_FILE" && -s "$OUTPUT_FILE" ]]; then
        echo "Output file size: $(stat -c%s "$OUTPUT_FILE") bytes"
        echo ""
        echo "First 20 lines of generated JavaScript:"
        echo "---------------------------------------"
        head -n 20 "$OUTPUT_FILE"
        echo ""
        
        # Check if output looks like valid JavaScript
        if head -n 1 "$OUTPUT_FILE" | grep -q "function\|var\|let\|const\|class"; then
            echo "✓ Valid JavaScript output generated"
        else
            echo "⚠ Output may not be valid JavaScript"
        fi
        
        # Check for common JavaScript patterns
        if grep -q "function\|var\|let\|const" "$OUTPUT_FILE"; then
            echo "✓ Contains JavaScript function/variable declarations"
        fi
        
        # Check for Roo-specific patterns
        if grep -q "Roo\." "$OUTPUT_FILE"; then
            echo "✓ Contains Roo framework references"
        fi
        
        # Check for widget creation patterns
        if grep -q "new.*Widget\|\.el\." "$OUTPUT_FILE"; then
            echo "✓ Contains widget creation patterns"
        fi
        
    else
        echo "ERROR: No output generated"
    fi
else
    echo "ERROR: Compilation failed (exit code: $?)"
    
    if [[ -f "$ERROR_FILE" && -s "$ERROR_FILE" ]]; then
        echo ""
        echo "Error details:"
        echo "--------------"
        cat "$ERROR_FILE"
    fi
fi

# Compare with existing JS file if it exists
EXISTING_JS="$PROJECT_DIR/${BJS_FILE%.bjs}.js"
if [[ -f "$EXISTING_JS" ]]; then
    echo ""
    echo "=== Comparison with Existing JS File ==="
    echo "Comparing with: $EXISTING_JS"
    
    if [[ -f "$OUTPUT_FILE" && -s "$OUTPUT_FILE" ]]; then
        EXISTING_SIZE=$(stat -c%s "$EXISTING_JS" 2>/dev/null || echo "0")
        NEW_SIZE=$(stat -c%s "$OUTPUT_FILE" 2>/dev/null || echo "0")
        
        echo "Existing JS file size: $EXISTING_SIZE bytes"
        echo "Generated JS file size: $NEW_SIZE bytes"
        
        if [[ "$EXISTING_SIZE" -eq "$NEW_SIZE" ]]; then
            echo "✓ File sizes match"
        else
            echo "⚠ File sizes differ by $((NEW_SIZE - EXISTING_SIZE)) bytes"
        fi
        
        # Show diff if files are different
        if ! cmp -s "$EXISTING_JS" "$OUTPUT_FILE"; then
            echo ""
                echo "Differences found (first 20 lines of diff):"
                echo "-------------------------------------------"
                diff -u -w "$EXISTING_JS" "$OUTPUT_FILE" | head -n 20
        else
            echo "✓ Generated file matches existing JS file exactly"
        fi
    else
        echo "⚠ Cannot compare - no generated output"
    fi
else
    echo "No existing JS file found for comparison"
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
    echo "✓ BJS compilation successful"
    echo "✓ JavaScript output generated"
    if [[ -f "$EXISTING_JS" ]] && cmp -s "$EXISTING_JS" "$OUTPUT_FILE"; then
        echo "✓ Generated output matches existing JS file"
    elif [[ -f "$EXISTING_JS" ]]; then
        echo "⚠ Generated output differs from existing JS file"
    else
        echo "ℹ No existing JS file to compare against"
    fi
else
    echo "❌ BJS compilation failed"
fi

echo ""
echo "Test results saved to: $TEST_DIR"
echo "Generated JS file: $OUTPUT_FILE"
if [[ -f "$ERROR_FILE" && -s "$ERROR_FILE" ]]; then
    echo "Error log: $ERROR_FILE"
fi
