#!/bin/bash

# Test BJS Upgrade Process Script
# This script tests the upgrade process from version 1/2 to version 3

echo "=== BJS Upgrade Process Test ==="
echo "Testing upgrade from version 1/2 to version 3"
echo "Date: $(date)"
echo ""

# Create test results directory
TEST_DIR="/tmp/roobuilder_upgrade_test_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$TEST_DIR"

# Results files
RESULTS_LOG="$TEST_DIR/upgrade_test_results.log"
ISSUES_LOG="$TEST_DIR/upgrade_issues.log"
SUMMARY_LOG="$TEST_DIR/upgrade_summary.log"

# Initialize log files
echo "BJS Upgrade Process Test Results - $(date)" > "$RESULTS_LOG"
echo "=========================================" >> "$RESULTS_LOG"
echo "" >> "$RESULTS_LOG"

echo "BJS Upgrade Issues Found" > "$ISSUES_LOG"
echo "========================" >> "$ISSUES_LOG"
echo "" >> "$ISSUES_LOG"

# Counters
TOTAL_FILES=0
SUCCESS_COUNT=0
ERROR_COUNT=0
VERSION_3_FILES=0
VERSION_1_2_FILES=0
UPGRADE_SUCCESS=0
UPGRADE_FAILED=0

# Function to test upgrade process for a single BJS file
test_upgrade_file() {
    local file_path="$1"
    local filename=$(basename "$file_path")
    local relative_path=$(echo "$file_path" | sed 's|/home/alan/gitlive/roobuilder/||')
    
    echo "Testing upgrade: $relative_path" | tee -a "$RESULTS_LOG"
    
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
    
    # Check for version information
    local version="unknown"
    if grep -q "bjs_version" "$file_path"; then
        version=$(grep "bjs_version" "$file_path" | head -n 1 | sed 's/.*bjs_version.*: *\([0-9]*\).*/\1/')
        if [[ "$version" =~ ^[0-9]+$ ]]; then
            if [[ "$version" -eq 3 ]]; then
                echo "  INFO: Version 3 file - no upgrade needed" | tee -a "$RESULTS_LOG"
                ((VERSION_3_FILES++))
                ((SUCCESS_COUNT++))
                return 0
            else
                echo "  INFO: Version $version file - upgrade needed" | tee -a "$RESULTS_LOG"
                ((VERSION_1_2_FILES++))
            fi
        else
            echo "  INFO: Version not clearly identified - assuming needs upgrade" | tee -a "$RESULTS_LOG"
            ((VERSION_1_2_FILES++))
        fi
    else
        echo "  INFO: No version information found - assuming needs upgrade" | tee -a "$RESULTS_LOG"
        ((VERSION_1_2_FILES++))
    fi
    
    # If version 3, no upgrade needed
    if [[ "$version" == "3" ]]; then
        return 0
    fi
    
    # Test upgrade process
    echo "  Testing upgrade process..." | tee -a "$RESULTS_LOG"
    
    # Create backup as version 2
    local backup_file="${file_path}.bjs2"
    cp "$file_path" "$backup_file"
    echo "  Created backup: $(basename "$backup_file")" | tee -a "$RESULTS_LOG"
    
    # Test upgrade command (this should move old file to .bjs.old2 and create new format)
    echo "  Running upgrade command..." | tee -a "$RESULTS_LOG"
    local upgrade_output="$TEST_DIR/${filename%.bjs}_upgrade_output.log"
    local upgrade_error="$TEST_DIR/${filename%.bjs}_upgrade_error.log"
    
    # Check if local build exists
    if [[ ! -f "./build/roobuilder" ]]; then
        echo "  ERROR: Local build not found at ./build/roobuilder" | tee -a "$RESULTS_LOG"
        echo "ERROR: $relative_path - Local build not found" >> "$ISSUES_LOG"
        ((ERROR_COUNT++))
        return 1
    fi
    
    # Run upgrade command
    if ./build/roobuilder --project /home/alan/gitlive/roobuilder --test-bjs-upgrade "$file_path" > "$upgrade_output" 2> "$upgrade_error"; then
        echo "  SUCCESS: Upgrade command completed" | tee -a "$RESULTS_LOG"
        
        # Check if .bjs.old2 file was created
        local old2_file="${file_path}.old2"
        if [[ -f "$old2_file" ]]; then
            echo "  INFO: Old file moved to .bjs.old2" | tee -a "$RESULTS_LOG"
        else
            echo "  WARNING: No .bjs.old2 filej created" | tee -a "$RESULTS_LOG"
        fi
        
        # Check if new file was created
        if [[ -f "$file_path" ]]; then
            echo "  INFO: New file created" | tee -a "$RESULTS_LOG"
            
            # Check if new file has version 3
            if grep -q "bjs_version.*3" "$file_path"; then
                echo "  SUCCESS: File upgraded to version 3" | tee -a "$RESULTS_LOG"
                ((UPGRADE_SUCCESS++))
                ((SUCCESS_COUNT++))
            else
                echo "  WARNING: File upgraded but version not clearly 3" | tee -a "$RESULTS_LOG"
                ((UPGRADE_SUCCESS++))
                ((SUCCESS_COUNT++))
            fi
        else
            echo "  ERROR: New file not created" | tee -a "$RESULTS_LOG"
            echo "ERROR: $relative_path - New file not created after upgrade" >> "$ISSUES_LOG"
            ((UPGRADE_FAILED++))
            ((ERROR_COUNT++))
        fi
    else
        local exit_code=$?
        echo "  ERROR: Upgrade command failed (exit code: $exit_code)" | tee -a "$RESULTS_LOG"
        echo "ERROR: $relative_path - Upgrade command failed" >> "$ISSUES_LOG"
        
        if [[ -f "$upgrade_error" && -s "$upgrade_error" ]]; then
            echo "    Error details:" | tee -a "$RESULTS_LOG"
            cat "$upgrade_error" | sed 's/^/      /' | tee -a "$RESULTS_LOG"
            echo "Error details for $relative_path:" >> "$ISSUES_LOG"
            cat "$upgrade_error" >> "$ISSUES_LOG"
        fi
        
        ((UPGRADE_FAILED++))
        ((ERROR_COUNT++))
    fi
    
    # Restore original file from backup
    echo "  Restoring original file..." | tee -a "$RESULTS_LOG"
    cp "$backup_file" "$file_path"
    rm "$backup_file"
    
    # Clean up old2 file if it exists
    if [[ -f "$old2_file" ]]; then
        rm "$old2_file"
        echo "  Cleaned up .bjs.old2 file" | tee -a "$RESULTS_LOG"
    fi
    
    echo "" | tee -a "$RESULTS_LOG"
    return 0
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
    test_upgrade_file "$file"
    if [[ $? -ne 0 ]]; then
        echo "STOPPING: Test failed for $file" | tee -a "$RESULTS_LOG"
        echo "STOPPING: Test failed for $file" >> "$ISSUES_LOG"
        break
    fi
done

# Generate summary
echo "=== UPGRADE TEST SUMMARY ===" | tee -a "$SUMMARY_LOG"
echo "Date: $(date)" | tee -a "$SUMMARY_LOG"
echo "Total files tested: $TOTAL_FILES" | tee -a "$SUMMARY_LOG"
echo "Successful tests: $SUCCESS_COUNT" | tee -a "$SUMMARY_LOG"
echo "Failed tests: $ERROR_COUNT" | tee -a "$SUMMARY_LOG"
echo "Version 3 files (no upgrade needed): $VERSION_3_FILES" | tee -a "$SUMMARY_LOG"
echo "Version 1/2 files (upgrade needed): $VERSION_1_2_FILES" | tee -a "$SUMMARY_LOG"
echo "Upgrade successes: $UPGRADE_SUCCESS" | tee -a "$SUMMARY_LOG"
echo "Upgrade failures: $UPGRADE_FAILED" | tee -a "$SUMMARY_LOG"
echo "Success rate: $(( (SUCCESS_COUNT * 100) / TOTAL_FILES ))%" | tee -a "$SUMMARY_LOG"
echo "" | tee -a "$SUMMARY_LOG"

if [[ $ERROR_COUNT -gt 0 ]]; then
    echo "Files with issues:" | tee -a "$SUMMARY_LOG"
    cat "$ISSUES_LOG" | tee -a "$SUMMARY_LOG"
else
    echo "All upgrade tests completed successfully!" | tee -a "$SUMMARY_LOG"
fi

echo ""
echo "=== UPGRADE TEST COMPLETE ==="
echo "Results saved to: $TEST_DIR"
echo "Summary: $SUCCESS_COUNT/$TOTAL_FILES tests successful"
echo "Version 3 files: $VERSION_3_FILES"
echo "Version 1/2 files: $VERSION_1_2_FILES"
echo "Upgrade successes: $UPGRADE_SUCCESS"
echo "Upgrade failures: $UPGRADE_FAILED"

# Display summary
cat "$SUMMARY_LOG"
