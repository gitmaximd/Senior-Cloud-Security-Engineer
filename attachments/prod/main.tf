data "terraform_remote_state" "bootstrap" {
  backend = "local"

  config = {
    path = "${path.module}/../../bootstrap/bootstrap.tfstate"
  }
}

module "attachments" {
  source = "../../modules/scp_stage_attachments"

  scp_attachments_file = "${path.module}/../../scp-attachments.prod.yaml"
  root_id              = data.terraform_remote_state.bootstrap.outputs.root_id
  ou_ids               = data.terraform_remote_state.bootstrap.outputs.ou_ids
  scp_ids              = data.terraform_remote_state.bootstrap.outputs.scp_ids
  account_ids          = data.terraform_remote_state.bootstrap.outputs.account_ids
}
