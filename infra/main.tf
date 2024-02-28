#
# hard-coded variables
#
locals {
  region1 = "us-east-1"
  region2 = "us-east-2"

  cluster1_cidr_block = "10.1.0.0/16"
  cluster2_cidr_block = "10.2.0.0/16"
  state1_cidr_block   = "10.10.0.0/24"
  state2_cidr_block   = "10.20.0.0/24"

  tags = {
    "cost-center"   = "CC468"
    "service-phase" = "lab"
    "app-code"      = "MOBB-001"
    "owner"         = "dscott_redhat.com"
    "provisioner"   = "Terraform"
  }
}

#
# provider config
#
provider "aws" {
  alias  = "primary"
  region = local.region1
}

provider "aws" {
  alias  = "secondary"
  region = local.region2
}

#
# input variables
#
variable "ocp_version" {
  default = "4.13.33"
}

variable "token" {
  sensitive = true
}

variable "admin_password" {
  sensitive = true
}

variable "developer_password" {
  sensitive = true
}

#
# primary region
#

# rosa cluster and networking
module "cluster1" {
  source = "git::https://github.com/scottd018-demos/terraform-rosa.git?ref=v0.0.16-alpha"

  private            = false
  multi_az           = false
  autoscaling        = true
  cluster_name       = "dscott1"
  ocp_version        = var.ocp_version
  token              = var.token
  admin_password     = var.admin_password
  developer_password = var.developer_password
  vpc_cidr           = local.cluster1_cidr_block
  region             = local.region1
  tags               = local.tags
}

# application state vpc and networking
module "state1" {
  source = "./network"

  network_name       = "dscott1-state"
  availability_zones = module.cluster1.private_subnet_azs
  vpc_cidr           = local.state1_cidr_block
  subnet_cidr_size   = 24
  region             = local.region1
  tags               = local.tags
}

# routing between vpcs
module "cluster1_to_state1_routing" {
  source = "./gateway"

  network_name = "dscott1-cluster-state"
  vpc_id_1     = module.cluster1.vpc_id
  vpc_id_2     = module.state1.vpc_id
  subnet_ids_1 = module.cluster1.private_subnet_ids
  subnet_ids_2 = module.state1.subnet_ids
  region       = local.region1
  tags         = local.tags
}

# peering vpcs
resource "aws_ec2_transit_gateway_peering_attachment" "replication" {
  provider = aws.primary

  peer_region             = local.region2
  peer_transit_gateway_id = module.cluster2_to_state2_routing.transit_gateway_id
  transit_gateway_id      = module.cluster1_to_state1_routing.transit_gateway_id

  tags = merge(local.tags, { "Name" = "dscott-replication" })
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "replication" {
  provider = aws.secondary

  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.replication.id

  tags = merge(local.tags, { "Name" = "dscott-replication" })
}

# routing for replication
resource "aws_route" "state1_to_state2" {
  provider = aws.primary

  route_table_id         = module.state1.route_table_ids[0]
  destination_cidr_block = local.state2_cidr_block
  transit_gateway_id     = module.cluster1_to_state1_routing.transit_gateway_id
}

#
# secondary region
#

# rosa cluster and networking
module "cluster2" {
  source = "git::https://github.com/scottd018-demos/terraform-rosa.git?ref=v0.0.16-alpha"

  private            = false
  multi_az           = false
  autoscaling        = true
  cluster_name       = "dscott2"
  ocp_version        = var.ocp_version
  token              = var.token
  admin_password     = var.admin_password
  developer_password = var.developer_password
  vpc_cidr           = local.cluster2_cidr_block
  region             = local.region2
  tags               = local.tags
}

# application state vpc and networking
module "state2" {
  source = "./network"

  network_name       = "dscott2-state"
  availability_zones = module.cluster2.private_subnet_azs
  vpc_cidr           = local.state2_cidr_block
  subnet_cidr_size   = 24
  region             = local.region2
  tags               = local.tags
}

# routing between vpcs
module "cluster2_to_state2_routing" {
  source = "./gateway"

  network_name = "dscott2-cluster-state"
  vpc_id_1     = module.cluster2.vpc_id
  vpc_id_2     = module.state2.vpc_id
  subnet_ids_1 = module.cluster2.private_subnet_ids
  subnet_ids_2 = module.state2.subnet_ids
  region       = local.region2
  tags         = local.tags
}

# routing for replication
resource "aws_route" "state2_to_state1" {
  provider = aws.secondary

  route_table_id         = module.state2.route_table_ids[0]
  destination_cidr_block = local.state1_cidr_block
  transit_gateway_id     = module.cluster2_to_state2_routing.transit_gateway_id
}
