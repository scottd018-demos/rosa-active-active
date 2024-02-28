resource "aws_ec2_transit_gateway_route_table" "gateway" {
  transit_gateway_id = aws_ec2_transit_gateway.gateway.id
  tags               = merge(var.tags, { "Name" = var.network_name })
}

resource "aws_ec2_transit_gateway_route" "vpc2_to_vpc1" {
  destination_cidr_block         = data.aws_vpc.vpc1.cidr_block
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.gateway.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc2.id
}

resource "aws_ec2_transit_gateway_route" "vpc1_to_vpc2" {
  destination_cidr_block         = data.aws_vpc.vpc2.cidr_block
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.gateway.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc1.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "vpc1" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.gateway.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "vpc2" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc2.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.gateway.id
}

resource "aws_route" "vpc1_to_vpc2" {
  count = length(data.aws_route_table.vpc1)

  route_table_id         = data.aws_route_table.vpc1[count.index].id
  destination_cidr_block = data.aws_vpc.vpc2.cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.gateway.id
}

resource "aws_route" "vpc2_to_vpc1" {
  count = length(data.aws_route_table.vpc2)

  route_table_id         = data.aws_route_table.vpc2[count.index].id
  destination_cidr_block = data.aws_vpc.vpc1.cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.gateway.id
}
