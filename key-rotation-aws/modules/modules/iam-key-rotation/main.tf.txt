# modules/iam-key-rotation/main.tf
# Create key1 when enabled
resource "aws_iam_access_key" "key1" {
  count = var.key1_enabled ? 1 : 0
  user  = var.username

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, {
    KeyName = "key1"
    Purpose = "Primary access key"
  })
}

# Create key2 when enabled
resource "aws_iam_access_key" "key2" {
  count = var.key2_enabled ? 1 : 0
  user  = var.username

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, {
    KeyName = "key2"
    Purpose = "Secondary access key for rotation"
  })
}
