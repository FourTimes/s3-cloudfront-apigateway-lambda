variable "accessKey" {}
variable "secretKey" {}
variable "region" {}
variable "project" {}
variable "environment" {}

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags for the Azure Firewall resources, in addition to the resource group tags."
}
