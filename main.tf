terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.52.0"
    }
  }
}

# 3. Create a Security Group to allow SSH access
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh_traffic"
  description = "Allow inbound SSH traffic"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # For production, restrict this to your IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

# 4. Define the EC2 Instance Resource
resource "aws_instance" "my_ec2" {
  ami           = "ami-0c7217cdde317cfec" # Ubuntu 22.04 LTS AMI ID for us-east-1
  instance_type = "t2.micro"             # Free-tier eligible size

  # Associate the security group created above
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  # Optional: Attach an existing AWS Key Pair name for SSH login
  # key_name = "your-aws-key-pair-name"

  tags = {
    Name        = "Terraform-EC2-Instance"
    Environment = "Dev"
  }
}

# 5. Output the public IP address after deployment
output "instance_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.my_ec2.public_ip
}
