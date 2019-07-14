output "main_vpc_id" {
    description = "The ID of the root VPC for this project"
    value = module.vpc.vpc_id_so_we_can_spot_easily
}

output "user_data" {
    value = data.aws_iam_user.helloitsme.arn
}

output "website_dns" {
    value = module.webserver.public_dns
}