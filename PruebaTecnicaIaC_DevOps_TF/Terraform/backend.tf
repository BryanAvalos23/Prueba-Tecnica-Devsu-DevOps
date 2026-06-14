terraform {
  backend "s3" {
    bucket  = "devsu-demo-app-iac"
    key     = "environments/dev.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
