output "ec2_public_ip" {
  value       = aws_instance.jenkins_server.public_ip
  description = "The public IP address of the Jenkins-Docker server."
}

output "jenkins_url" {
  value       = "http://${aws_instance.jenkins_server.public_ip}:8080"
  description = "The URL to access the Jenkins dashboard."
}

output "codecommit_clone_url" {
  value       = aws_codecommit_repository.app_repo.clone_url_http
  description = "Git clone URL for the CodeCommit repository."
}

output "s3_bucket_name" {
  value       = aws_s3_bucket.build_artifacts.id
  description = "The name of the S3 bucket used for build artifacts."
}

output "jenkins_unlock_instructions" {
  value       = "Run this command on the server to get the password: sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
  description = "Instructions to retrieve the initial Jenkins admin password."
}