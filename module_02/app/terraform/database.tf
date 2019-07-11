resource "aws_redshift_cluster" "practice_redshift" {
  cluster_identifier = "redshift-practice-cluster"
  database_name      = "salesforcedata"
  master_username    = "salesforcedi"
  master_password    = "Mustbe8characters"
  node_type          = "dc1.large"
  cluster_type       = "single-node"
  cluster_subnet_group_name = aws_redshift_subnet_group.rs_subnet.name
  skip_final_snapshot = true
  publicly_accessible = true
  vpc_security_group_ids = [aws_security_group.redshift_access.id]
  tags = {
    Environment = var.environment_tag
  } 
}

resource "aws_redshift_subnet_group" "rs_subnet" {
    name = "practicerssubnet"
    subnet_ids = [aws_subnet.subnet_public.id]
    tags = {
        Environment = var.environment_tag
    }     
}

resource "aws_security_group" "redshift_access" {
  name = "redshiftaccess"
  vpc_id = aws_vpc.practice_vpc.id
  ingress {
      from_port   = 5439
      to_port     = 5439
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