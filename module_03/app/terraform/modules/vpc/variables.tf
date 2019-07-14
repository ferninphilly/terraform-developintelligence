variable "cidr_vpc" {
  description = "CIDR block for the VPC"
  default = "10.0.0.0/16"
}

variable "cidr_subnet" {
  description = "CIDR block for the subnet"
  default = "10.0.0.0/24"
}
variable "availability_zone" {
  description = "availability zone to create the public subnet"
  default = "eu-west-1a"
}

variable "private_availability_zone" {
  description = "availability zone to create the public subnet"
  default = "eu-west-1b"
}

variable "private_cidr_subnet" {
  description = "CIDR block for the PRIVATE subnet"
  default = "10.0.1.0/24"
}

variable "environment_tag" {
    description = "This is the environment tag that we will use"
    default = "development"
}

variable "eip_id" {
    description = "The elastic IP for the webserver"
}