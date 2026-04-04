output "root_id" {
  value = local.root_id
}

output "ou_ids" {
  value = local.ou_ids
}

output "scp_ids" {
  value = {
    for k, v in aws_organizations_policy.scp : k => v.id
  }
}

output "account_ids" {
  value = local.accounts
}
