variable "network_name" {
  type        = string
  description = "Name of the network to create.  All subcomponents will be named with this as the prefix."
}

variable "vpc_id_1" {
  type        = string
  description = "First VPC to connect to the gateway."
}

variable "vpc_id_2" {
  type        = string
  description = "Second VPC to connect to the gateway."
}

variable "subnet_ids_1" {
  type        = list(string)
  description = "Subnet IDs within 'vpc_id_1' to connect to the gateway."
}

variable "subnet_ids_2" {
  type        = list(string)
  description = "Subnet IDs within 'vpc_id_2' to connect to the gateway."
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
