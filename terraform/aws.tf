variable "aws_profile" {
    default = "default"
}

provider "aws" {
   region  = "ap-southeast-1"
   profile = "${var.aws_profile}"
}
