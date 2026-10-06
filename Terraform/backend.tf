terraform {
  backend "s3" {
    bucket = "terraformansiblecicd"
    key    = "terraform/terraform.tfstate"
    region = "ap-south-1"
  }
}