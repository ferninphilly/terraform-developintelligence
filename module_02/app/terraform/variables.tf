variable "region" {
    type = "string"
    description = "This is the region we want to deploy to. If you want to change the region do it here"
    default = "eu-west-1"
}

variable "profile" {
    type= "string"
    description = "This is the string representation of the aws profile we want to use"
    default = "codices"
}

variable "ec2type" {
    type = "string"
    description = "This is the ami for the type of ec2 instance we want to deploy"
    default = "ami-03746875d916becc0"
}

variable "key_pair_name" {
    type = "string"
    description = "The key pair to access our ec2 instance"
    default = "practicekey"
}

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


