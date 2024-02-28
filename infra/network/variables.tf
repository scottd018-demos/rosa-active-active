variable "network_name" {
  type        = string
  description = "Name of the network to create.  All subcomponents will be named with this as the prefix."
}

variable "availability_zones" {
  type        = list(string)
  description = "Availability Zones where this VPC will have subnets within."
}

variable "vpc_cidr" {
  type        = string
  description = "VPC network, in CIDR notation format (e.g. 10.10.0.0/16)."
}

variable "subnet_cidr_size" {
  type        = number
  description = "Subnet CIDR mask.  Must be within the 'vpc_cidr' range."
}

variable "tags" {
  description = "Tags applied to all objects"
  type        = map(string)
  default = {
    "owner" = "dscott"
  }

  validation {
    condition     = (var.tags["owner"] != null && var.tags["owner"] != "")
    error_message = "Please specify the 'owner' tag as part of 'var.tags'."
  }
}

variable "region" {
  type    = string
  default = "us-east-1"
}
