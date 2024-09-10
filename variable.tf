variable "vpc_name" {
  type    = string
  default = "vpc_HA_3-Tire"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
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
