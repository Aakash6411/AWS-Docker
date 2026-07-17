# ==========================================
# 1. IAM ROLE FOR EC2 (Allows S3, CodeDeploy)
# ==========================================
resource "aws_iam_role" "ec2_role" {
  name = "ec2-jenkins-developer-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_full_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "codedeploy_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-jenkins-profile"
  role = aws_iam_role.ec2_role.name
}

# ==========================================
# 2. SECURITY GROUP (Ports: 22, 80, 8080)
# ==========================================
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-docker-sg"
  description = "Allow SSH, HTTP, and Jenkins traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
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

# ==========================================
# 3. EC2 INSTANCE WITH EBS
# ==========================================
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

resource "aws_instance" "jenkins_server" {
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = var.instance_type
  security_groups      = [aws_security_group.jenkins_sg.name]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  user_data            = file("userdata.sh")

  tags = {
    Name = "Jenkins-Docker-Server"
  }
}

resource "aws_ebs_volume" "docker_data" {
  availability_zone = aws_instance.jenkins_server.availability_zone
  size              = var.ebs_size

  tags = {
    Name = "Docker-Data-Volume"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.docker_data.id
  instance_id = aws_instance.jenkins_server.id
}

# ==========================================
# 4. S3 BUCKET (For Build Artifacts)
# ==========================================
resource "aws_s3_bucket" "build_artifacts" {
  bucket_prefix = "devops-build-artifacts-"
  force_destroy = true
}

# ==========================================
# 5. AWS DEVELOPER TOOLS
# ==========================================
resource "aws_codecommit_repository" "app_repo" {
  repository_name = "my-application-repo"
  description     = "Source code repository for my app"
}

resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_admin" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_codebuild_project" "app_build" {
  name          = "my-app-build"
  description   = "Builds Docker images"
  service_role  = aws_iam_role.codebuild_role.arn

artifacts {
    type     = "S3"
    location = aws_s3_bucket.build_artifacts.id 
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
  }

  source {
    type     = "CODECOMMIT"
    location = aws_codecommit_repository.app_repo.clone_url_http
  }
}

resource "aws_codedeploy_app" "app_deploy" {
  compute_platform = "Server"
  name             = "my-app-deploy"
}

resource "aws_iam_role" "codedeploy_service_role" {
  name = "codedeploy-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codedeploy_role_attach" {
  role       = aws_iam_role.codedeploy_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

resource "aws_codedeploy_deployment_group" "app_deploy_group" {
  app_name              = aws_codedeploy_app.app_deploy.name
  deployment_group_name = "dev-deployment-group"
  service_role_arn      = aws_iam_role.codedeploy_service_role.arn

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "Jenkins-Docker-Server"
    }
  }
}
