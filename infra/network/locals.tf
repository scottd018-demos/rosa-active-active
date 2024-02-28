locals {
  subnet_count = length(var.availability_zones)

  vpc_cidr_size = split("/", var.vpc_cidr)[1]

  _all_cidrs = [
    for index in range(local.subnet_count) :
    cidrsubnet(var.vpc_cidr, (var.subnet_cidr_size - local.vpc_cidr_size), index)
  ]

  subnets = slice(local._all_cidrs, 0, local.subnet_count)
}
