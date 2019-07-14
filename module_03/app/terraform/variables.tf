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

variable "environment_tag" {
    type="string"
    description = "The environment to tag resources with"
    default = "development"
}

data "aws_iam_user" "helloitsme" {
  user_name = "dimos"
}




