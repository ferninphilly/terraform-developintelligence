variable "ec2type" {
    type = "string"
    description = "This is the ami for the type of ec2 instance we want to deploy"
    default = "ami-047bb4163c506cd98"
}

variable "key_pair_name" {
    type = "string"
    description = "The key pair to access our ec2 instance"
    default = "practicekey"
}

variable "main_vpc_id" {
    type = "string"
}

variable "public_subnet_id" {
    type = "string"
    description = "The public subnet id"
}

variable "environment_tag" {
    type="string"
    description = "The environment to tag resources with"
    default = "development"
}
