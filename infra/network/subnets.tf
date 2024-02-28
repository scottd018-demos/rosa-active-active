resource "aws_subnet" "state" {
  count = local.subnet_count

  vpc_id                  = aws_vpc.state.id
  cidr_block              = local.subnets[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = merge(var.tags,
    {
      "Name" = "${var.network_name}-${var.availability_zones[count.index]}"
    }
  )
}
