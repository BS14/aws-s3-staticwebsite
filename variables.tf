variable "shop_name" {
  type    = string
  description = "Name of the shop."
  default = "SG Shop"
}

variable "bucket_region" {
  type    = string
  description = "AWS Region for creating Bucket."
  default = "eu-central-1"
}