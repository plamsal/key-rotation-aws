#!/bin/bash
# rotate-keys.sh - Helper script for AWS IAM key rotation

set -e

# Configuration
USERNAME=${1:-"test_user1"}
TERRAGRUNT_DIR=${2:-"."}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

get_current_state() {
    local key1_enabled=$(grep -E "key1_enabled\s*=" "$TERRAGRUNT_DIR/terragrunt.hcl" | grep -o "true\|false")
    local key2_enabled=$(grep -E "key2_enabled\s*=" "$TERRAGRUNT_DIR/terragrunt.hcl" | grep -o "true\|false")
    
    echo "key1:$key1_enabled,key2:$key2_enabled"
}

update_terragrunt_config() {
    local key1_state=$1
    local key2_state=$2
    
    sed -i.bak \
        -e "s/key1_enabled = .*/key1_enabled = $key1_state/" \
        -e "s/key2_enabled = .*/key2_enabled = $key2_state/" \
        "$TERRAGRUNT_DIR/terragrunt.hcl"
}

show_current_keys() {
    log "Checking current AWS access keys for user: $USERNAME"
    aws iam list-access-keys --user-name "$USERNAME" --output table || error "Failed to list access keys"
}

rotation_step1() {
    log "Step 1: Creating second key (overlap period)"
    show_current_keys
    update_terragrunt_config "true" "true"
    terragrunt apply
    log "Both keys are now active. Test your application with the new key."
}

rotation_step2() {
    log "Step 2: Removing first key (completing rotation)"
    show_current_keys
    update_terragrunt_config "false" "true"
    terragrunt apply
    log "Rotation complete. Only key2 is now active."
}

rotation_step3() {
    log "Step 3: Preparing for next rotation (optional)"
    show_current_keys
    update_terragrunt_config "true" "false"
    terragrunt apply
    log "Reset to key1 only. Ready for next rotation cycle."
}

full_rotation() {
    log "Performing full key rotation for user: $USERNAME"
    
    current_state=$(get_current_state)
    log "Current state: $current_state"
    
    case "$current_state" in
        "key1:true,key2:false")
            rotation_step1
            ;;
        "key1:true,key2:true")
            rotation_step2
            ;;
        "key1:false,key2:true")
            rotation_step3
            ;;
        *)
            error "Unexpected state: $current_state"
            ;;
    esac
}

show_help() {
    cat << EOF
AWS IAM Key Rotation Helper

Usage: $0 [USERNAME] [TERRAGRUNT_DIR]

Commands:
    step1       Create second key (key1=true, key2=true)
    step2       Remove first key (key1=false, key2=true)  
    step3       Reset to key1 (key1=true, key2=false)
    full        Perform next rotation step automatically
    status      Show current key status
    help        Show this help message

Examples:
    $0 test_user1 .                    # Show status for test_user1
    $0 test_user1 . step1              # Create second key
    $0 test_user1 . full               # Auto-rotate to next step

Environment Variables:
    AWS_PROFILE    AWS profile to use
    AWS_REGION     AWS region
EOF
}

# Main execution
case "${3:-status}" in
    "step1")
        rotation_step1
        ;;
    "step2")
        rotation_step2
        ;;
    "step3")
        rotation_step3
        ;;
    "full")
        full_rotation
        ;;
    "status")
        show_current_keys
        current_state=$(get_current_state)
        log "Terragrunt config state: $current_state"
        ;;
    "help")
        show_help
        ;;
    *)
        show_help
        ;;
esac