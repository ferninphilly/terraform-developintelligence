output "main_vpc_id" {
    description = "The ID of the root VPC for this project"
    value = module.vpc.vpc_id_so_we_can_spot_easily
}

output "public_subnet_id" {
    description = "The public subnet ID"
    value =module.vpc.public_subnet_id
}