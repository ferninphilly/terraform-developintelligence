output "public_dns" {
    value = aws_instance.myfirstec2.public_dns
}

output "public_ip" {
    value = aws_instance.myfirstec2.public_ip
}

output "practice_eip" {
    value = aws_eip.practice_eip.id
}

