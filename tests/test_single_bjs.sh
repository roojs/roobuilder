#!/bin/bash -x

# Test single BJS file compilation
# Usage: ./test_single_bjs.sh <bjs_file_path>

if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <bjs_file_path>"
    echo "Example: $0 src/Builder4/About.bjs"
    exit 1
fi

BJS_FILE="$1"
FILENAME=$(basename "$BJS_FILE")
TEST_DIR="/tmp/single_bjs_test_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$TEST_DIR"

echo "=== Single BJS File Test ==="
echo "Testing: $BJS_FILE"
echo "Date: $(date)"
echo ""

# Check if file exists
if [[ ! -f "$BJS_FILE" ]]; then
    echo "ERROR: File not found: $BJS_FILE"
    exit 1
fi

# Check file size
FILE_SIZE=$(stat -c%s "$BJS_FILE" 2>/dev/null || echo "0")
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
head -n 10 "$BJS_FILE"
echo ""

# Try different approaches to compile

echo "=== Approach 1: Direct compilation (using local build) ==="
echo "Command: ./build/roobuilder --project /home/alan/gitlive/roobuilder --test-symbol-target roobuilder --test-bjs-compile \"$BJS_FILE\""
echo ""

OUTPUT_FILE="$TEST_DIR/${FILENAME%.bjs}_output.vala"
ERROR_FILE="$TEST_DIR/${FILENAME%.bjs}_error.log"

# Check if local build exists
if [[ ! -f "../build/roobuilder" ]]; then
    echo "ERROR: Local build not found at ../build/roobuilder"
    echo "Please build the project first with: ninja -C build"
    exit 1
fi

# Run compilation
echo "Running compilation..."
if ../build/roobuilder --project /home/alan/gitlive/roobuilder --test-symbol-target roobuilder --test-bjs-compile "$BJS_FILE" > "$OUTPUT_FILE" 2> "$ERROR_FILE"; then
    echo "SUCCESS: Compilation completed"
    
    if [[ -f "$OUTPUT_FILE" && -s "$OUTPUT_FILE" ]]; then
        echo "Output file size: $(stat -c%s "$OUTPUT_FILE") bytes"
        echo ""
        echo "First 10 lines of output:"
        echo "-------------------------"
        head -n 10 "$OUTPUT_FILE"
        echo ""
        
        # Check if output starts with static
        if head -n 1 "$OUTPUT_FILE" | grep -q "^static"; then
            echo "✓ Clean Vala output (starts with 'static')"
        else
            echo "⚠ Output may contain garbage (doesn't start with 'static')"
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

echo ""
echo "=== Approach 2: Using absolute path (local build) ==="
ABSOLUTE_FILE=$(realpath "$BJS_FILE")
echo "Absolute path: $ABSOLUTE_FILE"
echo "Command: ./build/roobuilder --project /home/alan/gitlive/roobuilder --test-symbol-target roobuilder --test-bjs-compile \"$ABSOLUTE_FILE\""
echo ""

OUTPUT_FILE2="$TEST_DIR/${FILENAME%.bjs}_output2.vala"
ERROR_FILE2="$TEST_DIR/${FILENAME%.bjs}_error2.log"

if ../build/roobuilder --project /home/alan/gitlive/roobuilder --test-symbol-target roobuilder --test-bjs-compile "$ABSOLUTE_FILE" > "$OUTPUT_FILE2" 2> "$ERROR_FILE2"; then
    echo "SUCCESS: Compilation with absolute path completed"
    
    if [[ -f "$OUTPUT_FILE2" && -s "$OUTPUT_FILE2" ]]; then
        echo "Output file size: $(stat -c%s "$OUTPUT_FILE2") bytes"
        echo "✓ Clean Vala output generated with absolute path"
    else
        echo "ERROR: No output generated with absolute path"
    fi
else
    echo "ERROR: Compilation with absolute path failed (exit code: $?)"
    
    if [[ -f "$ERROR_FILE2" && -s "$ERROR_FILE2" ]]; then
        echo ""
        echo "Error details:"
        echo "--------------"
        cat "$ERROR_FILE2"
    fi
fi

echo ""
echo "=== File Information ==="
echo "File: $BJS_FILE"
echo "Absolute path: $ABSOLUTE_FILE"
echo "Working directory: $(pwd)"
echo "Project directory: /home/alan/gitlive/roobuilder"

# Check if file is in the project
if [[ "$BJS_FILE" == src/* ]]; then
    echo "✓ File is in src/ directory"
else
    echo "⚠ File is not in src/ directory"
fi

# Check for version information
if grep -q "bjs_version" "$BJS_FILE"; then
    VERSION=$(grep "bjs_version" "$BJS_FILE" | head -n 1 | sed 's/.*bjs_version.*: *\([0-9]*\).*/\1/')
    echo "Version found: $VERSION"
else
    echo "No version information found"
fi

echo ""
echo "Test results saved to: $TEST_DIR"
