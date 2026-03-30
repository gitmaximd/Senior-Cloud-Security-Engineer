variable "name" {
  type = string
  description = "The name of the Organizational Unit (OU)"
}

variable "parent_id" {
  type = string
  description = "The ID of a parent Organizational Unit (OU) where the new OU will be created"
}