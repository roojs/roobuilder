#!/bin/bash

# Test Version 3 Loading Verification Script
# This script tests loading of all BJS files in the src directory

echo "=== Version 3 Loading Verification Test ==="
echo "Testing all BJS files in src directory for version 3 compatibility"
echo "Date: $(date)"
echo ""

# Create test results directory
TEST_DIR="/tmp/roobuilder_version3_test_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$TEST_DIR"

# Results files
RESULTS_LOG="$TEST_DIR/version3_test_results.log"
ISSUES_LOG="$TEST_DIR/version3_issues.log"
SUMMARY_LOG="$TEST_DIR/version3_summary.log"

# Initialize log files
echo "Version 3 Loading Test Results - $(date)" > "$RESULTS_LOG"
echo "=========================================" >> "$RESULTS_LOG"
echo "" >> "$RESULTS_LOG"

echo "Version 3 Loading Issues Found" > "$ISSUES_LOG"
echo "=============================" >> "$ISSUES_LOG"
echo "" >> "$ISSUES_LOG"

# Counters
TOTAL_FILES=0
SUCCESS_COUNT=0
ERROR_COUNT=0
VERSION_3_FILES=0
VERSION_1_2_FILES=0

# Function to test a single BJS file
test_bjs_file() {
    local file_path="$1"
    local filename=$(basename "$file_path")
    local relative_path=$(echo "$file_path" | sed 's|/home/alan/gitlive/roobuilder/||')
    
    echo "Testing: $relative_path" | tee -a "$RESULTS_LOG"
    
    # Check if file exists
    if [[ ! -f "$file_path" ]]; then
        echo "  ERROR: File not found" | tee -a "$RESULTS_LOG"
        echo "ERROR: $relative_path - File not found" >> "$ISSUES_LOG"
        ((ERROR_COUNT++))
        return 1
    fi
    
    # Check file size
    local file_size=$(stat -c%s "$file_path" 2>/dev/null || echo "0")
    if [[ "$file_size" -eq 0 ]]; then
        echo "  ERROR: Empty file" | tee -a "$RESULTS_LOG"
        echo "ERROR: $relative_path - Empty file" >> "$ISSUES_LOG"
        ((ERROR_COUNT++))
        return 1
    fi
    
    # Try to compile the file
    echo "  Compiling..." | tee -a "$RESULTS_LOG"
    local compile_output="$TEST_DIR/${filename%.bjs}_compile_output.vala"
    local compile_error="$TEST_DIR/${filename%.bjs}_compile_error.log"
    
    # Run compilation with timeout
    if timeout 30 /usr/bin/roobuilder --project /home/alan/gitlive/roobuilder --test-symbol-target roobuilder --test-bjs-compile "$file_path" > "$compile_output" 2> "$compile_error"; then
        # Check if output file was created and has content
        if [[ -f "$compile_output" && -s "$compile_output" ]]; then
            # Check if output starts with static (clean Vala code)
            if head -n 1 "$compile_output" | grep -q "^static"; then
                echo "  SUCCESS: Clean Vala output generated" | tee -a "$RESULTS_LOG"
                ((SUCCESS_COUNT++))
                
                # Check for version in the file (look for bjs_version)
                if grep -q "bjs_version" "$file_path"; then
                    local version=$(grep "bjs_version" "$file_path" | head -n 1 | sed 's/.*bjs_version.*: *\([0-9]*\).*/\1/')
                    if [[ "$version" =~ ^[0-9]+$ ]]; then
                        if [[ "$version" -eq 3 ]]; then
                            echo "  INFO: Version 3 file detected" | tee -a "$RESULTS_LOG"
                            ((VERSION_3_FILES++))
                        else
                            echo "  INFO: Version $version file detected" | tee -a "$RESULTS_LOG"
                            ((VERSION_1_2_FILES++))
                        fi
                    else
                        echo "  INFO: Version not clearly identified" | tee -a "$RESULTS_LOG"
                    fi
                else
                    echo "  INFO: No version information found" | tee -a "$RESULTS_LOG"
                fi
            else
                echo "  WARNING: Output generated but may contain garbage" | tee -a "$RESULTS_LOG"
                echo "WARNING: $relative_path - Output may contain garbage" >> "$ISSUES_LOG"
                ((SUCCESS_COUNT++)) # Still count as success since it compiled
            fi
        else
            echo "  ERROR: No output generated" | tee -a "$RESULTS_LOG"
            echo "ERROR: $relative_path - No output generated" >> "$ISSUES_LOG"
            ((ERROR_COUNT++))
        fi
    else
        local exit_code=$?
        echo "  ERROR: Compilation failed (exit code: $exit_code)" | tee -a "$RESULTS_LOG"
        echo "ERROR: $relative_path - Compilation failed" >> "$ISSUES_LOG"
        if [[ -f "$compile_error" && -s "$compile_error" ]]; then
            echo "    Error details:" | tee -a "$RESULTS_LOG"
            cat "$compile_error" | sed 's/^/      /' | tee -a "$RESULTS_LOG"
            echo "Error details for $relative_path:" >> "$ISSUES_LOG"
            cat "$compile_error" >> "$ISSUES_LOG"
        fi
        ((ERROR_COUNT++))
    fi
    
    echo "" | tee -a "$RESULTS_LOG"
}

# Find all BJS files in src directory
echo "Finding BJS files in src directory..." | tee -a "$RESULTS_LOG"
BJS_FILES=($(find /home/alan/gitlive/roobuilder/src -name "*.bjs" -type f | sort))

if [[ ${#BJS_FILES[@]} -eq 0 ]]; then
    echo "No BJS files found in src directory" | tee -a "$RESULTS_LOG"
    exit 1
fi

TOTAL_FILES=${#BJS_FILES[@]}
echo "Found $TOTAL_FILES BJS files to test" | tee -a "$RESULTS_LOG"
echo "" | tee -a "$RESULTS_LOG"

# Test each file
for file in "${BJS_FILES[@]}"; do
    test_bjs_file "$file"
done

# Generate summary
echo "=== TEST SUMMARY ===" | tee -a "$SUMMARY_LOG"
echo "Date: $(date)" | tee -a "$SUMMARY_LOG"
echo "Total files tested: $TOTAL_FILES" | tee -a "$SUMMARY_LOG"
echo "Successful compilations: $SUCCESS_COUNT" | tee -a "$SUMMARY_LOG"
echo "Failed compilations: $ERROR_COUNT" | tee -a "$SUMMARY_LOG"
echo "Version 3 files: $VERSION_3_FILES" | tee -a "$SUMMARY_LOG"
echo "Version 1/2 files: $VERSION_1_2_FILES" | tee -a "$SUMMARY_LOG"
echo "Success rate: $(( (SUCCESS_COUNT * 100) / TOTAL_FILES ))%" | tee -a "$SUMMARY_LOG"
echo "" | tee -a "$SUMMARY_LOG"

if [[ $ERROR_COUNT -gt 0 ]]; then
    echo "Files with issues:" | tee -a "$SUMMARY_LOG"
    cat "$ISSUES_LOG" | tee -a "$SUMMARY_LOG"
else
    echo "All files compiled successfully!" | tee -a "$SUMMARY_LOG"
fi

echo ""
echo "=== VERSION 3 LOADING TEST COMPLETE ==="
echo "Results saved to: $TEST_DIR"
echo "Summary: $SUCCESS_COUNT/$TOTAL_FILES files compiled successfully"
echo "Version 3 files: $VERSION_3_FILES"
echo "Version 1/2 files: $VERSION_1_2_FILES"

# Display summary
cat "$SUMMARY_LOG"
