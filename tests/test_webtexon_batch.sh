#!/bin/bash -x

# Test multiple BJS files from web.Texon/Pman/Shipping project
# Usage: ./test_webtexon_batch.sh [file_pattern] [max_files]
# Examples:
#   ./test_webtexon_batch.sh                    # Test all files
#   ./test_webtexon_batch.sh "Pman\.Tab\."      # Test only Tab files
#   ./test_webtexon_batch.sh "Pman\.Dialog\."   # Test only Dialog files
#   ./test_webtexon_batch.sh "Pman\.Tab\." 5    # Test first 5 Tab files

# Configuration
PROJECT_DIR="/home/alan/gitlive/web.Texon/Pman/Shipping"
PATTERN="${1:-*.bjs}"
MAX_FILES="${2:-10}"
TEST_DIR="../tests/results"
mkdir -p "$TEST_DIR"

# Results tracking
RESULTS_LOG="$TEST_DIR/webtexon_batch_results.log"
SUCCESS_COUNT=0
FAILED_COUNT=0
DIFF_COUNT=0
TOTAL_COUNT=0

echo "=== Web.Texon Batch BJS Test ==="
echo "Pattern: $PATTERN"
echo "Max files: $MAX_FILES"
echo "Project: $PROJECT_DIR"
echo "Date: $(date)"
echo ""

# Check if roobuilder build exists
if [[ ! -f "../build/roobuilder" ]]; then
    echo "ERROR: Local build not found at ../build/roobuilder"
    echo "Please build the project first with: ninja -C build"
    exit 1
fi

# Find BJS files matching pattern
echo "=== Finding BJS Files ==="
if [[ "$PATTERN" == "*.bjs" ]]; then
    # If pattern is just *.bjs, find all BJS files
    FILES=($(find "$PROJECT_DIR" -name "*.bjs" -type f | head -n "$MAX_FILES"))
else
    # For specific patterns, search for files that match the pattern
    FILES=($(find "$PROJECT_DIR" -name "*.bjs" -type f | grep -E "$PATTERN" | head -n "$MAX_FILES"))
fi

if [[ ${#FILES[@]} -eq 0 ]]; then
    echo "ERROR: No BJS files found matching pattern: $PATTERN"
    exit 1
fi

echo "Found ${#FILES[@]} files to test:"
for file in "${FILES[@]}"; do
    echo "  - $(basename "$file")"
done
echo ""

# Test each file
echo "=== Testing Files ==="
for file in "${FILES[@]}"; do
    TOTAL_COUNT=$((TOTAL_COUNT + 1))
    filename=$(basename "$file")
    echo "Testing $TOTAL_COUNT/${#FILES[@]}: $filename"
    
    # Run compilation - files go directly in results directory
    OUTPUT_FILE="$TEST_DIR/${filename%.bjs}_generated.js"
    ERROR_FILE="$TEST_DIR/${filename%.bjs}_error.log"
    DIFF_FILE="$TEST_DIR/${filename%.bjs}.diff"
    
            echo "  Compiling..." | tee -a "$RESULTS_LOG"
            echo "  Command: ../build/roobuilder --project \"$PROJECT_DIR\" --test-bjs-compile \"$filename\"" | tee -a "$RESULTS_LOG"
            echo "Command: ../build/roobuilder --project \"$PROJECT_DIR\" --test-bjs-compile \"$filename\"" > "$ERROR_FILE"
            if ../build/roobuilder --project "$PROJECT_DIR" --test-bjs-compile "$filename" > "$OUTPUT_FILE" 2>> "$ERROR_FILE"; then
        echo "  ✓ Compilation successful" | tee -a "$RESULTS_LOG"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        
        # Check if output was generated
        if [[ -f "$OUTPUT_FILE" && -s "$OUTPUT_FILE" ]]; then
            echo "  ✓ JavaScript output generated ($(stat -c%s "$OUTPUT_FILE") bytes)" | tee -a "$RESULTS_LOG"
            
            # Compare with existing JS file if it exists
            EXISTING_JS="$PROJECT_DIR/${filename%.bjs}.js"
            if [[ -f "$EXISTING_JS" ]]; then
                if cmp -s "$EXISTING_JS" "$OUTPUT_FILE"; then
                    echo "  ✓ Generated output matches existing JS file" | tee -a "$RESULTS_LOG"
                else
                    echo "  ⚠ Generated output differs from existing JS file" | tee -a "$RESULTS_LOG"
                    DIFF_COUNT=$((DIFF_COUNT + 1))
                    
                    # Save full diff to file (unified diff with whitespace ignore)
                    diff -u -w "$EXISTING_JS" "$OUTPUT_FILE" > "$DIFF_FILE"
                    
                    # Show first few differences
                    echo "    Differences (first 5 lines):" | tee -a "$RESULTS_LOG"
                    head -n 5 "$DIFF_FILE" | sed 's/^/      /' | tee -a "$RESULTS_LOG"
                fi
            else
                echo "  ℹ No existing JS file to compare against" | tee -a "$RESULTS_LOG"
            fi
        else
            echo "  ⚠ No output generated" | tee -a "$RESULTS_LOG"
        fi
    else
        echo "  ❌ Compilation failed" | tee -a "$RESULTS_LOG"
        FAILED_COUNT=$((FAILED_COUNT + 1))
        
        # Show error details
        if [[ -f "$ERROR_FILE" && -s "$ERROR_FILE" ]]; then
            echo "    Error details:" | tee -a "$RESULTS_LOG"
            head -n 5 "$ERROR_FILE" | sed 's/^/      /' | tee -a "$RESULTS_LOG"
        fi
    fi
    
    echo "" | tee -a "$RESULTS_LOG"
done

# Summary
echo "=== Batch Test Summary ==="
echo "Total files tested: $TOTAL_COUNT"
echo "Successful compilations: $SUCCESS_COUNT"
echo "Failed compilations: $FAILED_COUNT"
echo "Files with differences: $DIFF_COUNT"
echo ""

# Calculate success rate
if [[ $TOTAL_COUNT -gt 0 ]]; then
    SUCCESS_RATE=$((SUCCESS_COUNT * 100 / TOTAL_COUNT))
    echo "Success rate: $SUCCESS_RATE%"
fi

# Show failed files
if [[ $FAILED_COUNT -gt 0 ]]; then
    echo ""
    echo "Failed files:"
    grep "❌ Compilation failed" "$RESULTS_LOG" | sed 's/.*Testing [0-9]*\/[0-9]*: /  - /'
fi

# Show files with differences
if [[ $DIFF_COUNT -gt 0 ]]; then
    echo ""
    echo "Files with differences:"
    grep "⚠ Generated output differs" "$RESULTS_LOG" | sed 's/.*Testing [0-9]*\/[0-9]*: /  - /'
fi

echo ""
echo "Detailed results saved to: $RESULTS_LOG"
echo "Generated JS files: $TEST_DIR/*_generated.js"
echo "Diff files: $TEST_DIR/*.diff"
echo "Error logs: $TEST_DIR/*_error.log"

# Exit with error code if any failures
if [[ $FAILED_COUNT -gt 0 ]]; then
    exit 1
else
    exit 0
fi
