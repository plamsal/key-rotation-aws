# terragrunt.hcl (root level)
terraform {
  source = "./modules/iam-key-rotation"
}

# Include common configuration
include "root" {
  path = find_in_parent_folders()
}

# Environment-specific inputs
inputs = {
  username     = "test_user1"
  key1_enabled = true   # Set to false to disable/delete key1
  key2_enabled = false  # Set to true to create key2
  
  tags = {
    Environment   = "production"
    ManagedBy    = "terraform"
    Purpose      = "key-rotation"
    Owner        = "devops-team"
  }
}

# Example usage scenarios:

# Scenario 1: Initial state - only key1 active
# inputs = {
#   username     = "test_user1"
#   key1_enabled = true
#   key2_enabled = false
# }

# Scenario 2: Create key2 while keeping key1 (overlap period)
# inputs = {
#   username     = "test_user1"
#   key1_enabled = true
#   key2_enabled = true
# }

# Scenario 3: Switch to key2 only (remove key1)
# inputs = {
#   username     = "test_user1"
#   key1_enabled = false
#   key2_enabled = true
# }

# Scenario 4: Switch back to key1 (remove key2)
# inputs = {
#   username     = "test_user1"
#   key1_enabled = true
#   key2_enabled = false
# }
