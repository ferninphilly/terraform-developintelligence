provider "aws" {
  profile    =  var.profile
  region     =  var.region
}

module "webserver" {
    source = "./modules/services/webserver"
   
}

module "vpc" {
    source = "./modules/vpc"
}


