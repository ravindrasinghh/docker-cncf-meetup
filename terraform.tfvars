env = "docker"
cluster_name = "docker-meetup-cluster"
ami_id       = "ami-014cdb1bfb3b2584f"

provider_base          = 0
provider_weight        = 1
capacity_provider_name = "docker-meetup-capacity-provider"
desired_count          = 1
instance_type          = "t3a.micro"

#server sg rules
server_ingress_rules = {
  1 = {
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    from_port       = 80
    to_port         = 80
    security_groups = null
  }
  2 = {
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    from_port       = 443
    to_port         = 443
    security_groups = null
  }
}
server_egress_rules = {
  1 = {
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    from_port       = 0
    to_port         = 0
    security_groups = null
  }
}
vpc_conf = {
  cidr_block           = "192.168.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
}
# Public Subnets
public_subnet = {
  public-subnet-1 = {
    cidr_block        = "192.168.1.0/24"
    availability_zone = "us-west-2a"
  }
  public-subnet-2 = {
    cidr_block        = "192.168.2.0/24"
    availability_zone = "us-west-2b"
  }
}
