locals {
  scp_attachment_data = yamldecode(file(var.scp_attachments_file))

  scp_attachments_by_key = {
    for item in concat(
      [
        for policy_key in try(local.scp_attachment_data.root.policies, []) : {
          attachment_key = "root:${policy_key}"
          policy_key     = policy_key
          target_id      = var.root_id
        }
      ],
      flatten([
        for ou in try(local.scp_attachment_data.organizational_units, []) : [
          for policy_key in try(ou.policies, []) : {
            attachment_key = "ou:${ou.target}:${policy_key}"
            policy_key     = policy_key
            target_id      = var.ou_ids[ou.target]
          }
        ]
      ]),
      flatten([
        for account in try(local.scp_attachment_data.accounts, []) : [
          for policy_key in try(account.policies, []) : {
            attachment_key = "account:${account.target}:${policy_key}"
            policy_key     = policy_key
            target_id      = var.account_ids[account.target]
          }
        ]
      ])
    ) :
    item.attachment_key => item
  }
}

module "scp_attachments" {
  source = "../scp_attachment"

  for_each = local.scp_attachments_by_key

  policy_id = var.scp_ids[each.value.policy_key]
  target_id = each.value.target_id
}
