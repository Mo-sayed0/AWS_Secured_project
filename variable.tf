variable "vpc_name" {
  type    = string
  default = "demo_vpc_HA"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "private_subnets" {
  default = {
    "private_subnet_1" = 1
    "private_subnet_2" = 2
  }
}
variable "private_subnets_2" {
  default = {
    "private_subnet_1" = 1
    "private_subnet_2" = 2
  }
}
variable "public_subnets" {
  default = {
    "public_subnet_1" = 1
  }
}
variable "public_subnets_2" {
  default = {
    "public_subnet_1" = 1
  }
}

variable "availability_zone" {
  default = {
    "availability_zone_1a" = "us-east-1a"
    "availability_zone_1b" = "us-east-1b"
    "availability_zone_1c" = "us-east-1c"
    "availability_zone_1d" = "us-east-1d"
    "availability_zone_1e" = "us-east-1e"
    "availability_zone_1f" = "us-east-1f"
  }
}
