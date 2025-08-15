# modules/iam-key-rotation/outputs.tf
output "key1_id" {
  description = "Access Key ID for key1"
  value       = var.key1_enabled ? aws_iam_access_key.key1[0].id : null
}

output "key1_secret" {
  description = "Secret Access Key for key1"
  value       = var.key1_enabled ? aws_iam_access_key.key1[0].secret : null
  sensitive   = true
}

output "key2_id" {
  description = "Access Key ID for key2"
  value       = var.key2_enabled ? aws_iam_access_key.key2[0].id : null
}

output "key2_secret" {
  description = "Secret Access Key for key2"
  value       = var.key2_enabled ? aws_iam_access_key.key2[0].secret : null
  sensitive   = true
}

output "active_key_id" {
  description = "Currently active key ID"
  value = var.key1_enabled && var.key2_enabled ? "Both keys active" : (
    var.key1_enabled ? aws_iam_access_key.key1[0].id : (
      var.key2_enabled ? aws_iam_access_key.key2[0].id : "No keys active"
    )
  )
}
