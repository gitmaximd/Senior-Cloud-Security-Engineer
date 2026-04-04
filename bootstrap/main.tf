module "bootstrap" {
  source = "../modules/bootstrap"

  org_structure_file = var.org_structure_file
  scp_policy_files   = var.scp_policy_files
}
