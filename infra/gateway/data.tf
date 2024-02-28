data "aws_vpc" "vpc1" {
  id = var.vpc_id_1
}

data "aws_vpc" "vpc2" {
  id = var.vpc_id_2
}

data "aws_route_table" "vpc1" {
  count = length(var.subnet_ids_1)

  subnet_id = var.subnet_ids_1[count.index]
}

data "aws_route_table" "vpc2" {
  count = length(var.subnet_ids_2)

  subnet_id = var.subnet_ids_2[count.index]
}
