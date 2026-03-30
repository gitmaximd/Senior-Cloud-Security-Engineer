locals {
  org_data = yamldecode(file(var.org_structure_file))

  root_id = data.aws_organizations_organization.current.roots[0].id

  organizational_units = {
    for ou in try(local.org_data.organizational_units, []) :
    ou.key => merge(ou, {
      scps = try(ou.scps, [])
    })
  }

  ou_level_1_ids = { for k, m in module.ou_level_1 : k => m.id }
  ou_level_2_ids = merge(
    local.ou_level_1_ids,
    { for k, m in module.ou_level_2 : k => m.id }
  )
  ou_level_3_ids = merge(
    local.ou_level_2_ids,
    { for k, m in module.ou_level_3 : k => m.id }
  )
  ou_level_4_ids = merge(
    local.ou_level_3_ids,
    { for k, m in module.ou_level_4 : k => m.id }
  )
  ou_ids = merge(
    local.ou_level_4_ids,
    { for k, m in module.ou_level_5 : k => m.id }
  )

  scp_attachments_by_key = {
    for item in concat(
      [
        for policy_key in try(local.org_data.root.scps, []) : {
          attachment_key = "root:${policy_key}"
          policy_key     = policy_key
          target_id      = local.root_id
          target_type    = "root"
          target_key     = "root"
        }
      ],
      flatten([
        for ou_key, ou in local.organizational_units : [
          for policy_key in ou.scps : {
            attachment_key = "ou:${ou_key}:${policy_key}"
            policy_key     = policy_key
            target_id      = local.ou_ids[ou_key]
            target_type    = "ou"
            target_key     = ou_key
          }
        ]
      ])
    ) :
    item.attachment_key => item
  }
}


data "aws_organizations_organization" "current" {}

resource "aws_organizations_policy" "scp" {
  for_each    = var.scp_policy_files
  name        = each.key
  description = "Managed by Terraform"
  type        = "SERVICE_CONTROL_POLICY"
  content     = file(each.value)
}

module "ou_level_1" {
  source = "./modules/org_unit"

  for_each = {
    for k, v in local.organizational_units : k => v if v.level == 1
  }

  name      = each.value.name
  parent_id = local.root_id
}

module "ou_level_2" {
  source = "./modules/org_unit"

  for_each = {
    for k, v in local.organizational_units : k => v if v.level == 2
  }

  name      = each.value.name
  parent_id = local.ou_level_1_ids[each.value.parent]

  depends_on = [module.ou_level_1]
}

module "ou_level_3" {
  source = "./modules/org_unit"

  for_each = {
    for k, v in local.organizational_units : k => v if v.level == 3
  }

  name      = each.value.name
  parent_id = local.ou_level_2_ids[each.value.parent]

  depends_on = [module.ou_level_2]
}

module "ou_level_4" {
  source = "./modules/org_unit"

  for_each = {
    for k, v in local.organizational_units : k => v if v.level == 4
  }

  name      = each.value.name
  parent_id = local.ou_level_3_ids[each.value.parent]

  depends_on = [module.ou_level_3]
}

module "ou_level_5" {
  source = "./modules/org_unit"

  for_each = {
    for k, v in local.organizational_units : k => v if v.level == 5
  }

  name      = each.value.name
  parent_id = local.ou_level_4_ids[each.value.parent]

  depends_on = [module.ou_level_4]
}

module "scp_attachments" {
  source = "./modules/scp_attachment"

  for_each = local.scp_attachments_by_key

  policy_id = aws_organizations_policy.scp[each.value.policy_key].id
  target_id = each.value.target_id
}
