#!/bin/bash

# Test single BJS file upgrade process
# Usage: ./test_single_upgrade.sh <bjs_file_path>

if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <bjs_file_path>"
    echo "Example: $0 src/Builder4/About.bjs"
    exit 1
fi

BJS_FILE="$1"
FILENAME=$(basename "$BJS_FILE")
TEST_DIR="/tmp/single_upgrade_test_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$TEST_DIR"

echo "=== Single BJS Upgrade Test ==="
echo "Testing upgrade: $BJS_FILE"
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

# Check for version information
echo "=== Version Check ==="
if grep -q "bjs_version" "$BJS_FILE"; then
    VERSION=$(grep "bjs_version" "$BJS_FILE" | head -n 1 | sed 's/.*bjs_version.*: *\([0-9]*\).*/\1/')
    echo "Version found in file: $VERSION"
else
    echo "No version information found in file"
fi

# Test upgrade command
echo ""
echo "=== Testing Upgrade Command ==="
echo "Command: ./build/roobuilder --project /home/alan/gitlive/roobuilder --test-bjs-upgrade \"$BJS_FILE\""
echo ""

OUTPUT_FILE="$TEST_DIR/${FILENAME%.bjs}_upgrade_output.json"
ERROR_FILE="$TEST_DIR/${FILENAME%.bjs}_upgrade_error.log"

# Check if local build exists
if [[ ! -f "../build/roobuilder" ]]; then
    echo "ERROR: Local build not found at ../build/roobuilder"
    echo "Please build the project first with: ninja -C build"
    exit 1
fi

# Convert relative path to project-relative path
if [[ "$BJS_FILE" == ../src/* ]]; then
    PROJECT_RELATIVE_FILE="${BJS_FILE#../}"
    echo "Using project-relative path: $PROJECT_RELATIVE_FILE"
else
    PROJECT_RELATIVE_FILE="$BJS_FILE"
fi

# Run upgrade command
echo "Running upgrade command..."
if ../build/roobuilder --project /home/alan/gitlive/roobuilder --test-bjs-upgrade "$PROJECT_RELATIVE_FILE" > "$OUTPUT_FILE" 2> "$ERROR_FILE"; then
    echo "SUCCESS: Upgrade command completed"
    
    if [[ -f "$OUTPUT_FILE" && -s "$OUTPUT_FILE" ]]; then
        echo "Output file size: $(stat -c%s "$OUTPUT_FILE") bytes"
        echo ""
        echo "Upgrade output (first 20 lines):"
        echo "--------------------------------"
        head -n 20 "$OUTPUT_FILE"
        echo ""
        
        # Check if output contains version information
        if grep -q "bjs-version" "$OUTPUT_FILE"; then
            UPGRADE_VERSION=$(grep "bjs-version" "$OUTPUT_FILE" | head -n 1 | sed 's/.*"bjs-version" *: *\([0-9]*\).*/\1/')
            echo "Upgraded version: $UPGRADE_VERSION"
            
            if [[ "$UPGRADE_VERSION" == "3" ]]; then
                echo "✓ File is already version 3 - no upgrade needed"
            else
                echo "⚠ File upgraded to version $UPGRADE_VERSION"
            fi
        else
            echo "⚠ No version information in upgrade output"
        fi
    else
        echo "ERROR: No output generated"
    fi
else
    echo "ERROR: Upgrade command failed (exit code: $?)"
    
    if [[ -f "$ERROR_FILE" && -s "$ERROR_FILE" ]]; then
        echo ""
        echo "Error details:"
        echo "--------------"
        cat "$ERROR_FILE"
    fi
fi

echo ""
echo "=== File Information ==="
echo "File: $BJS_FILE"
echo "Working directory: $(pwd)"
echo "Project directory: /home/alan/gitlive/roobuilder"

# Check if file is in the project
if [[ "$BJS_FILE" == src/* ]]; then
    echo "✓ File is in src/ directory"
else
    echo "⚠ File is not in src/ directory"
fi

echo ""
echo "Test results saved to: $TEST_DIR"
