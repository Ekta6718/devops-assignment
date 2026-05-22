terraform {
  backend "s3" {
    bucket = "ekta-devops-tf-state"
    key    = "terraform.tfstate"
    region = "ap-south-1"
  }
}