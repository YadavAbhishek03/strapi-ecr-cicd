terraform {
  backend "s3" {
    bucket = "abhi-terraform-state-bucket"  # Replace with your bucket name
    key    = "terraform/terraform.tfstate"  # Specify the path to your state file where your .tfstate file
    region = "us-east-1"
    encrypt = true  # Enables encryption for state file
  }
}
