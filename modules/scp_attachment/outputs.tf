output "policy_id" {
  value = aws_organizations_policy_attachment.this.policy_id
}

output "target_id" {
  value = aws_organizations_policy_attachment.this.target_id
}