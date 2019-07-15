provider "aws" {
  profile    =  var.profile
  region     =  var.region
}

terraform {  
    backend "s3" {
        bucket         = "fern-remote-terraform-state"
        key            = "terraform.tfstate"    
        region         = "eu-west-1"
        dynamodb_table = "fern-state-lock-dynamo"
    }
}

data "terraform_remote_state" "vpc" {
    backend = "s3"
    config = {
        bucket = "fern-remote-terraform-state"
        key = "terraform.tfstate"
        region = var.region
    }
}

module "webserver" {
    source = "./modules/services/webserver"
    main_vpc_id = data.terraform_remote_state.vpc.outputs.main_vpc_id
    public_subnet_id = data.terraform_remote_state.vpc.outputs.public_subnet_id
}

module "vpc" {
    source = "./modules/vpc"
}




