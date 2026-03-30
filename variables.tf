variable "org_structure_file" {
  description = "Path to the org structure YAML file"
  type        = string
  default     = "./org-structure.yaml"
}

variable "scp_policy_files" {
  description = "Map of SCP logical key to JSON file path"
  type        = map(string)
  default = {
    deny-leave-org  = "./policies/deny-leave-org.json"
    prod-guardrails = "./policies/prod-guardrails.json"
  }
}