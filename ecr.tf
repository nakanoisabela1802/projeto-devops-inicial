resource "aws_ecr_repository" "ecr-site" {
  name                 = "ecr-site-prod"
  image_tag_mutability = "MUTABLE"
}