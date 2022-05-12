terraform {
  backend "s3" {
    bucket = "vorx-infra-sandy"
    key    = "contador-app.tfstate"
    region = "us-east-1"
  }
}
