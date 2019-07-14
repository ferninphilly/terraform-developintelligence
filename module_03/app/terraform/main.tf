provider "aws" {
  profile    =  var.profile
  region     =  var.region
}

module "webserver" {
    source = "./modules/services/webserver"
    main_vpc_id = module.vpc.vpc_id_so_we_can_spot_easily
    public_subnet_id = module.vpc.public_subnet_id
}

module "vpc" {
    source = "./modules/vpc"
    eip_id = module.webserver.practice_eip
}


