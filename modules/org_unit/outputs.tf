output "id" {
  value = aws_organizations_organizational_unit.this.id
  description = "The ID of an Organizational Unit (OU)"
}

output "arn" {
  value = aws_organizations_organizational_unit.this.arn
}

output "name" {
  value = aws_organizations_organizational_unit.this.name
}