output "vpc_id_so_we_can_spot_easily" {
    value = aws_vpc.practice_vpc.id
}

output "public_subnet_id" {
    value = aws_subnet.subnet_public.id
}