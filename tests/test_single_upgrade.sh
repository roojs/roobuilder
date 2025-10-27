#!/bin/bash -x

# Test single BJS file upgrade process
# Usage: ./test_single_upgrade.sh <bjs_file_path>

if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <bjs_file_path>"
    echo "Example: $0 src/Builder4/About.bjs"
    exit 1
fi

BJS_FILE="$1"
FILENAME=$(basename "$BJS_FILE")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$SCRIPT_DIR/results"
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

# Convert relative path to project-relative path
if [[ "$BJS_FILE" == ../src/* ]]; then
    PROJECT_RELATIVE_FILE="${BJS_FILE#../}"
    echo "Using project-relative path: $PROJECT_RELATIVE_FILE"
else
    PROJECT_RELATIVE_FILE="$BJS_FILE"
fi

# Test upgrade command
echo ""
echo "=== Testing Upgrade Command ==="
echo "Command: ./build/roobuilder --project /home/alan/gitlive/roobuilder --test-bjs-upgrade \"$BJS_FILE\""
echo ""
echo "=== Manual Command for Review ==="
echo "To manually run the upgrade command and review results:"
echo "cd /home/alan/gitlive/roobuilder"
echo "./build/roobuilder --project /home/alan/gitlive/roobuilder --test-bjs-upgrade \"$PROJECT_RELATIVE_FILE\""
echo ""

OUTPUT_FILE="$TEST_DIR/${FILENAME%.bjs}_upgrade_output.json"
ERROR_FILE="$TEST_DIR/${FILENAME%.bjs}_upgrade_error.log"

# Check if local build exists
if [[ ! -f "../build/roobuilder" ]]; then
    echo "ERROR: Local build not found at ../build/roobuilder"
    echo "Please build the project first with: ninja -C build"
    exit 1
fi

# Run upgrade command
echo "Running upgrade command..."
if ../build/roobuilder --project /home/alan/gitlive/roobuilder --test-bjs-upgrade "$PROJECT_RELATIVE_FILE" > "$OUTPUT_FILE" 2> "$ERROR_FILE"; then
    # Check if the application actually crashed by examining the output
    # Only check for actual crashes, not warnings that don't prevent execution
    if grep -q "Trace/breakpoint trap\|core dumped\|Segmentation fault\|Aborted" "$ERROR_FILE" 2>/dev/null; then
        echo "ERROR: Application crashed during execution"
        echo "Error details:"
        echo "--------------"
        cat "$ERROR_FILE"
        echo ""
        echo "STOPPING: Cannot proceed with crashed application"
        exit 1
    fi
    
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

# Secondary test: Compare original with version 3 output
echo ""
echo "=== Secondary Test: Version 3 Comparison ==="

# Check if we have upgrade output to work with
if [[ -f "$OUTPUT_FILE" && -s "$OUTPUT_FILE" ]]; then
    echo "Performing version 3 comparison test..."
    
    # Create backup of original file
    ORIGINAL_BACKUP="$TEST_DIR/${FILENAME%.bjs}_original.bjs2"
    cp "$BJS_FILE" "$ORIGINAL_BACKUP"
    echo "✓ Original file backed up as: $ORIGINAL_BACKUP"
    
    # Check if the upgrade output contains version 3
    if grep -q '"bjs-version" *: *3' "$OUTPUT_FILE"; then
        echo "✓ Upgrade output contains version 3 data"
        
        # Generate version 3 BJS file from the JSON output
        echo "Generating version 3 BJS file..."
        # Save the .bjs3 file in the same directory as the original file
        ORIGINAL_DIR=$(dirname "$BJS_FILE")
        VERSION3_BJS_FILE="$ORIGINAL_DIR/${FILENAME%.bjs}.bjs3"
        
        # The upgrade output is already the correct BJS version 3 format
        # Just copy it to the .bjs3 file
        cp "$OUTPUT_FILE" "$VERSION3_BJS_FILE"
        
        echo "✓ Version 3 BJS file generated: $VERSION3_BJS_FILE"
        echo "File size: $(stat -c%s "$VERSION3_BJS_FILE") bytes"
        echo ""
        echo "Version 3 BJS content:"
        echo "---------------------"
        cat "$VERSION3_BJS_FILE"
        echo ""
        
        # Test consistency: run the upgrade command again on the same file
        echo "Testing upgrade consistency (running upgrade command again)..."
        CONSISTENCY_OUTPUT_FILE="$TEST_DIR/${FILENAME%.bjs}_consistency_output.json"
        CONSISTENCY_ERROR_FILE="$TEST_DIR/${FILENAME%.bjs}_consistency_error.log"
        
        if ../build/roobuilder --project /home/alan/gitlive/roobuilder --test-bjs-upgrade "$PROJECT_RELATIVE_FILE" > "$CONSISTENCY_OUTPUT_FILE" 2> "$CONSISTENCY_ERROR_FILE"; then
            # Check if the application actually crashed by examining the output
            # Only check for actual crashes, not warnings that don't prevent execution
            if grep -q "Trace/breakpoint trap\|core dumped\|Segmentation fault\|Aborted" "$CONSISTENCY_ERROR_FILE" 2>/dev/null; then
                echo "ERROR: Application crashed during consistency test"
                echo "Error details:"
                echo "--------------"
                cat "$CONSISTENCY_ERROR_FILE"
                echo ""
                echo "STOPPING: Cannot proceed with crashed application"
                exit 1
            fi
            
            echo "SUCCESS: Consistency test completed"
            
            if [[ -f "$CONSISTENCY_OUTPUT_FILE" && -s "$CONSISTENCY_OUTPUT_FILE" ]]; then
                echo "Consistency output file size: $(stat -c%s "$CONSISTENCY_OUTPUT_FILE") bytes"
                
                # Compare the two outputs
                echo ""
                echo "=== Upgrade Consistency Comparison ==="
                if diff -q "$OUTPUT_FILE" "$CONSISTENCY_OUTPUT_FILE" >/dev/null 2>&1; then
                    echo "✓ SUCCESS: Upgrade command produces consistent output"
                    echo "✓ The upgrade process is deterministic and reliable"
                else
                    echo "⚠ DIFFERENCE: Upgrade outputs are not identical"
                    echo "This suggests the upgrade process may not be deterministic"
                    echo "Differences found:"
                    diff "$OUTPUT_FILE" "$CONSISTENCY_OUTPUT_FILE" | head -n 20
                fi
                
                # Show first few lines of consistency output for verification
                echo ""
                echo "Consistency test output (first 10 lines):"
                echo "----------------------------------------"
                head -n 10 "$CONSISTENCY_OUTPUT_FILE"
            else
                echo "ERROR: No consistency test output generated"
            fi
        else
            echo "ERROR: Consistency test failed (exit code: $?)"
            if [[ -f "$CONSISTENCY_ERROR_FILE" && -s "$CONSISTENCY_ERROR_FILE" ]]; then
                echo "Consistency test error details:"
                echo "--------------------------------"
                cat "$CONSISTENCY_ERROR_FILE"
            fi
        fi
        
    else
        echo "⚠ No version 3 data found in upgrade output"
        echo "The file may not have been upgraded to version 3"
        
        # Check what version was actually produced
        if grep -q '"bjs-version"' "$OUTPUT_FILE"; then
            ACTUAL_VERSION=$(grep '"bjs-version"' "$OUTPUT_FILE" | head -n 1 | sed 's/.*"bjs-version" *: *\([0-9]*\).*/\1/')
            echo "Actual version in output: $ACTUAL_VERSION"
        else
            echo "No version information found in upgrade output"
        fi
    fi
else
    echo "⚠ Cannot perform version 3 comparison - no upgrade output available"
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
