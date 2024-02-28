resource "aws_vpc" "state" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = merge(var.tags,
    {
      "Name" = var.network_name
    }
  )
}
