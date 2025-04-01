terraform {
  backend "s3" {
    bucket = "k8s-project-with-myroslav"
    key    = "k8s-project/prod-eks/terraform.tfstate"
    region = "us-east-1"
  }
}
