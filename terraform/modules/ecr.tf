resource "aws_ecr_repository" "url-app-hub" {
  name                 = "url-app"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }

}