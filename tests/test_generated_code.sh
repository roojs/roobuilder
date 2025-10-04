#!/bin/bash

# Comprehensive Testing Script for Generated Code Output
# Tests JavaScript and Vala generation from BJS files
# Creates detailed issue reports and checklists

set -e

# Configuration
ROOBUILDER_PATH="/usr/bin/roobuilder"
ROOBUILDER_PROJECT="/home/alan/gitlive/roobuilder"
WEBTEXON_PATH="/home/alan/gitlive/web.Texon"
GITLIVE_PATH="/home/alan/gitlive/gitlive"
TEST_DIR="/tmp/code_generation_test_$(date +%Y%m%d_%H%M%S)"
LOG_FILE="$TEST_DIR/test_results.log"
ISSUE_FILE="$TEST_DIR/issues_checklist.md"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create test directory
mkdir -p "$TEST_DIR"
echo "Test directory created: $TEST_DIR"

# Logging function
log() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

# Error handling
handle_error() {
    log "${RED}ERROR: $1${NC}"
    log "${RED}Test failed at line $2${NC}"
    exit 1
}

# Clean output function (removes file structure dumps)
clean_output() {
    local input_file="$1"
    local output_file="$2"
    
    # Remove lines that start with "File /" (file structure dumps)
    # Keep only lines starting with "static" or later (actual code)
    sed -n '/^static/,$p' "$input_file" > "$output_file"
    
    # If no "static" found, try other patterns
    if [ ! -s "$output_file" ]; then
        # Try to find the actual start of the code
        sed -n '/^[a-zA-Z]/,$p' "$input_file" > "$output_file"
    fi
    
    # If still empty, copy the original
    if [ ! -s "$output_file" ]; then
        cp "$input_file" "$output_file"
    fi
}

# Test single BJS file
test_bjs_file() {
    local bjs_file="$1"
    local test_type="$2"  # "js" or "vala"
    local expected_file="$3"
    local test_name="$4"
    
    log "${BLUE}Testing: $test_name${NC}"
    log "  BJS file: $bjs_file"
    log "  Expected: $expected_file"
    
    # Generate output
    local temp_output="$TEST_DIR/$(basename "$bjs_file" .bjs)_generated.$test_type"
    local clean_output="$TEST_DIR/$(basename "$bjs_file" .bjs)_clean.$test_type"
    
    # Run roobuilder
    if [ "$test_type" = "js" ]; then
        # For JavaScript, we need to check if there's a specific JS generation method
        # For now, use the same command but expect JS output
        "$ROOBUILDER_PATH" --project "$ROOBUILDER_PROJECT" --test-symbol-target roobuilder --test-bjs-compile "$bjs_file" > "$temp_output" 2>&1 || true
    else
        # For Vala
        "$ROOBUILDER_PATH" --project "$ROOBUILDER_PROJECT" --test-symbol-target roobuilder --test-bjs-compile "$bjs_file" > "$temp_output" 2>&1 || true
    fi
    
    # Clean the output
    clean_output "$temp_output" "$clean_output"
    
    # Check if expected file exists
    if [ ! -f "$expected_file" ]; then
        log "  ${YELLOW}WARNING: Expected file does not exist: $expected_file${NC}"
        echo "- [ ] **$test_name**: Expected file missing - $expected_file" >> "$ISSUE_FILE"
        return 1
    fi
    
    # Compare files
    if diff -q "$clean_output" "$expected_file" > /dev/null 2>&1; then
        log "  ${GREEN}SUCCESS: Files match${NC}"
        return 0
    else
        log "  ${RED}FAILURE: Files differ${NC}"
        echo "- [ ] **$test_name**: Generated code differs from expected" >> "$ISSUE_FILE"
        echo "  - BJS: $bjs_file" >> "$ISSUE_FILE"
        echo "  - Expected: $expected_file" >> "$ISSUE_FILE"
        echo "  - Generated: $clean_output" >> "$ISSUE_FILE"
        echo "  - Diff: diff $expected_file $clean_output" >> "$ISSUE_FILE"
        echo "" >> "$ISSUE_FILE"
        return 1
    fi
}

# Initialize issue file
cat > "$ISSUE_FILE" << 'EOF'
# Code Generation Test Issues Checklist

This checklist contains all issues found during comprehensive testing of generated code output.

## Test Summary
- Test Date: $(date)
- Test Directory: $TEST_DIR
- Total Tests: TBD
- Passed: TBD
- Failed: TBD

## Issues Found

EOF

log "${GREEN}=== Starting Comprehensive Code Generation Testing ===${NC}"
log "Test directory: $TEST_DIR"
log "Log file: $LOG_FILE"
log "Issue checklist: $ISSUE_FILE"

# Test 1: JavaScript Generation with web.Texon Shipping files
log "${BLUE}=== Test 1: JavaScript Generation (web.Texon Shipping) ===${NC}"
shipping_bjs_count=0
shipping_js_count=0

if [ -d "$WEBTEXON_PATH/Pman/Shipping" ]; then
    for bjs_file in "$WEBTEXON_PATH/Pman/Shipping"/*.bjs; do
        if [ -f "$bjs_file" ]; then
            shipping_bjs_count=$((shipping_bjs_count + 1))
            js_file="${bjs_file%.bjs}.js"
            if [ -f "$js_file" ]; then
                shipping_js_count=$((shipping_js_count + 1))
                test_bjs_file "$bjs_file" "js" "$js_file" "JS: $(basename "$bjs_file")"
            else
                log "${YELLOW}WARNING: No corresponding JS file for $bjs_file${NC}"
                echo "- [ ] **JS Missing**: No corresponding JS file for $(basename "$bjs_file")" >> "$ISSUE_FILE"
            fi
        fi
    done
    log "Found $shipping_bjs_count BJS files, $shipping_js_count corresponding JS files"
else
    log "${RED}ERROR: web.Texon Shipping directory not found: $WEBTEXON_PATH/Pman/Shipping${NC}"
    echo "- [ ] **CRITICAL**: web.Texon Shipping directory not found" >> "$ISSUE_FILE"
fi

# Test 2: Vala Generation with roobuilder Builder4 files
log "${BLUE}=== Test 2: Vala Generation (roobuilder Builder4) ===${NC}"
builder4_bjs_count=0
builder4_vala_count=0

if [ -d "$ROOBUILDER_PROJECT/src/Builder4" ]; then
    for bjs_file in "$ROOBUILDER_PROJECT/src/Builder4"/*.bjs; do
        if [ -f "$bjs_file" ]; then
            builder4_bjs_count=$((builder4_bjs_count + 1))
            vala_file="${bjs_file%.bjs}.vala"
            if [ -f "$vala_file" ]; then
                builder4_vala_count=$((builder4_vala_count + 1))
                test_bjs_file "$bjs_file" "vala" "$vala_file" "Vala: $(basename "$bjs_file")"
            else
                log "${YELLOW}WARNING: No corresponding Vala file for $bjs_file${NC}"
                echo "- [ ] **Vala Missing**: No corresponding Vala file for $(basename "$bjs_file")" >> "$ISSUE_FILE"
            fi
        fi
    done
    log "Found $builder4_bjs_count BJS files, $builder4_vala_count corresponding Vala files"
else
    log "${RED}ERROR: roobuilder Builder4 directory not found: $ROOBUILDER_PROJECT/src/Builder4${NC}"
    echo "- [ ] **CRITICAL**: roobuilder Builder4 directory not found" >> "$ISSUE_FILE"
fi

# Test 3: Vala Generation with gitlive files
log "${BLUE}=== Test 3: Vala Generation (gitlive) ===${NC}"
gitlive_bjs_count=0
gitlive_vala_count=0

if [ -d "$GITLIVE_PATH" ]; then
    for bjs_file in "$GITLIVE_PATH"/*.bjs; do
        if [ -f "$bjs_file" ]; then
            gitlive_bjs_count=$((gitlive_bjs_count + 1))
            vala_file="${bjs_file%.bjs}.vala"
            if [ -f "$vala_file" ]; then
                gitlive_vala_count=$((gitlive_vala_count + 1))
                test_bjs_file "$bjs_file" "vala" "$vala_file" "Gitlive: $(basename "$bjs_file")"
            else
                log "${YELLOW}WARNING: No corresponding Vala file for $bjs_file${NC}"
                echo "- [ ] **Vala Missing**: No corresponding Vala file for $(basename "$bjs_file")" >> "$ISSUE_FILE"
            fi
        fi
    done
    log "Found $gitlive_bjs_count BJS files, $gitlive_vala_count corresponding Vala files"
else
    log "${RED}ERROR: gitlive directory not found: $GITLIVE_PATH${NC}"
    echo "- [ ] **CRITICAL**: gitlive directory not found" >> "$ISSUE_FILE"
fi

# Generate summary
log "${BLUE}=== Test Summary ===${NC}"
total_bjs=$((shipping_bjs_count + builder4_bjs_count + gitlive_bjs_count))
total_output=$((shipping_js_count + builder4_vala_count + gitlive_vala_count))

log "Total BJS files tested: $total_bjs"
log "Total output files found: $total_output"
log "Test results saved to: $LOG_FILE"
log "Issue checklist saved to: $ISSUE_FILE"

# Update issue file with summary
sed -i "s/Total Tests: TBD/Total Tests: $total_bjs/" "$ISSUE_FILE"
sed -i "s/Total Output Files: TBD/Total Output Files: $total_output/" "$ISSUE_FILE"

log "${GREEN}=== Testing Complete ===${NC}"
log "Next steps:"
log "1. Review the issue checklist: $ISSUE_FILE"
log "2. Categorize issues by type and priority"
log "3. Create action plan for addressing issues"
log "4. Fix command line generation if needed"
log "5. Re-run tests after fixes"

exit 0
