resource "aws_ec2_transit_gateway" "gateway" {
  tags = merge(var.tags, { "Name" = var.network_name })
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc1" {
  transit_gateway_id = aws_ec2_transit_gateway.gateway.id
  vpc_id             = data.aws_vpc.vpc1.id
  subnet_ids         = var.subnet_ids_1
  tags               = merge(var.tags, { "Name" = var.network_name })
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc2" {
  transit_gateway_id = aws_ec2_transit_gateway.gateway.id
  vpc_id             = data.aws_vpc.vpc2.id
  subnet_ids         = var.subnet_ids_2
  tags               = merge(var.tags, { "Name" = var.network_name })
}
