
output "redshift_connection" {
    value = aws_redshift_cluster.practice_redshift.dns_name
}

output "redshift_endpoint" {
    value = aws_redshift_cluster.practice_redshift.endpoint
}