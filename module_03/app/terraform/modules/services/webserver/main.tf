resource "aws_instance" "myfirstec2" {
  ami           = var.ec2type
  instance_type = "t2.micro"
  key_name = "myec2key"
  subnet_id = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.ssh_access.id, aws_security_group.sg_80.id]

  provisioner "remote-exec" {
    inline = ["sudo yum -y install python"]

     connection {
        host        = self.public_dns
        type        = "ssh"
        user        = "ec2-user"
        private_key = "${file("./keys/practicekey")}"
    }
  }


provisioner "local-exec" {
    command = "ansible-playbook -u ec2-user -i '${self.public_ip},' --private-key ./keys/practicekey ../ansible/playbook.yaml" 
  }

  tags = {
      Environment = var.environment_tag
    }
}

resource "aws_security_group" "ssh_access" {
  name = "ssh_access"
  vpc_id = var.main_vpc_id
  ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
 egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags =  {
    Environment = var.environment_tag
  }
}

resource "aws_security_group" "sg_80" {
  name = "sg_80"
  vpc_id = var.main_vpc_id

  ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_eip" "practice_eip" {
  vpc       = true
  tags = {
    Environment = var.environment_tag
  }
}

resource "aws_key_pair" "ec2key" {
  key_name   = "myec2key"
  public_key = file("./keys/practicekey.pub")
}

