# state.tf
terraform {
  backend "s3" {
    bucket  = "terraform-state-lab-devops-saori"
    key     = "site/terraform.tfstate"
    region  = "us-east-2"
    encrypt = true
  }
}
