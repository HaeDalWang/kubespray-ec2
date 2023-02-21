#---------------------------------------------------------------
# VPC 생성
#---------------------------------------------------------------

module "vpc" {
  source          = "terraform-aws-modules/vpc/aws"
  version         = "~> 3.0"
  name            = local.name
  cidr            = "172.20.0.0/16"
  azs             = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
  public_subnets  = ["172.20.0.0/22", "172.20.4.0/22", "172.20.8.0/22"]
  private_subnets = ["172.20.100.0/22", "172.20.104.0/22", "172.20.108.0/22"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${local.name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${local.name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${local.name}-default" }

  tags = local.tags
}
