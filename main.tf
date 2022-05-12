data "aws_vpc" "vorx_vpc" {
    filter {
        name = "tag:Name"
        values = ["vorx-prod-vpc"]
    }
}

data "aws_subnet" "vorx_public_sub_1a" {
    filter {
        name = "tag:Name"
        values = ["vorx-prod-vpc-public-us-east-1a"]
    }
}

module "pointer_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "Pointer SG"
  description = "Security group for Jenkins"
  vpc_id      = data.aws_vpc.vorx_vpc.id
  ingress_with_cidr_blocks = [
    {
      from_port     = 5000
      to_port       = 5000
      protocol      = "tcp"
      description   = "Contador app"
      cidr_blocks   = "0.0.0.0/0"
    },
    {
      from_port     = 22
      to_port       = 22
      protocol      = "tcp"
      description   = "porta ssh"
      cidr_blocks   = "0.0.0.0/0"
    }
  ]
  egress_rules             = ["all-all"]
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "Pointer"

  ami                    = "ami-07d02ee1eeb0c996c"
  instance_type          = "t2.micro"
  key_name               = "vockey"
  monitoring             = true
  vpc_security_group_ids = [module.pointer_sg.security_group_id]
  subnet_id              = data.aws_subnet.vorx_public_sub_1a.id
  user_data              = file("./dependencias.sh")

  tags = {
    Terraform = "true"
    Environment = "Production"
    CC = "10502"
    OwnerSquad = "Osaka"
    OwnerSRE =  "Valfenda"
  }
}

resource "aws_eip" "pointer-ip" {
  instance = module.ec2_instance.id
  vpc      = true

  tags = {
    Name = "Pointer-Server-IP"
  }
}