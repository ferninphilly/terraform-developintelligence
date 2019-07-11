output "public_dns" {
    value = aws_instance.myfirstec2.public_dns
}

output "public_ip" {
    value = aws_instance.myfirstec2.public_ip
}

output "vpc_id_so_we_can_spot_easily" {
    value = aws_vpc.practice_vpc.id
}

output "redshift_connection" {
    value = aws_redshift_cluster.practice_redshift.dns_name
}

output "redshift_endpoint" {
    value = aws_redshift_cluster.practice_redshift.endpoint
}