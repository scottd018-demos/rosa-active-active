output "subnet_ids" {
  value = [for net in aws_subnet.state : net.id]
}

output "subnet_azs" {
  value = [for net in aws_subnet.state : net.availability_zone]
}

output "route_table_ids" {
  value = [for rt in aws_route_table.state : rt.id]
}

output "vpc_id" {
  value = aws_vpc.state.id
}
