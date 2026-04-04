variable "scp_attachments_file" {
  description = "Path to the SCP attachments YAML file for the current stage"
  type        = string
}

variable "root_id" {
  description = "AWS Organizations root ID"
  type        = string
}

variable "ou_ids" {
  description = "Map of OU key to OU ID"
  type        = map(string)
}

variable "scp_ids" {
  description = "Map of SCP logical key to SCP ID"
  type        = map(string)
}

variable "account_ids" {
  description = "Map of account key to AWS account ID"
  type        = map(string)
  default     = {}
}
