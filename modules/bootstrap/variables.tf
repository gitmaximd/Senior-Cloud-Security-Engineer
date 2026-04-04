variable "org_structure_file" {
  description = "Path to the org structure YAML file"
  type        = string
}

variable "scp_policy_files" {
  description = "Map of SCP logical key to JSON file path"
  type        = map(string)
}
