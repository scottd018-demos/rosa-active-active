resource "aws_route_table" "state" {
  count = local.subnet_count

  vpc_id = aws_vpc.state.id

  tags = merge(var.tags,
    {
      "Name" = "${var.network_name}-${var.availability_zones[count.index]}"
    }
  )
}

resource "aws_route_table_association" "state" {
  count = local.subnet_count

  subnet_id      = aws_subnet.state[count.index].id
  route_table_id = aws_route_table.state[count.index].id
}
