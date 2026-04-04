locals {
  org_data = yamldecode(file(var.org_structure_file))

  root_id = data.aws_organizations_organization.current.roots[0].id

  organizational_units = {
    for ou in try(local.org_data.organizational_units, []) :
    ou.key => ou
  }

  accounts = {
    for account in try(local.org_data.accounts, []) :
    account.key => account.id
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
  source = "../org_unit"

  for_each = {
    for k, v in local.organizational_units : k => v if v.level == 1
  }

  name      = each.value.name
  parent_id = local.root_id
}

module "ou_level_2" {
  source = "../org_unit"

  for_each = {
    for k, v in local.organizational_units : k => v if v.level == 2
  }

  name      = each.value.name
  parent_id = local.ou_level_1_ids[each.value.parent]

  depends_on = [module.ou_level_1]
}

module "ou_level_3" {
  source = "../org_unit"

  for_each = {
    for k, v in local.organizational_units : k => v if v.level == 3
  }

  name      = each.value.name
  parent_id = local.ou_level_2_ids[each.value.parent]

  depends_on = [module.ou_level_2]
}

module "ou_level_4" {
  source = "../org_unit"

  for_each = {
    for k, v in local.organizational_units : k => v if v.level == 4
  }

  name      = each.value.name
  parent_id = local.ou_level_3_ids[each.value.parent]

  depends_on = [module.ou_level_3]
}

module "ou_level_5" {
  source = "../org_unit"

  for_each = {
    for k, v in local.organizational_units : k => v if v.level == 5
  }

  name      = each.value.name
  parent_id = local.ou_level_4_ids[each.value.parent]

  depends_on = [module.ou_level_4]
}
