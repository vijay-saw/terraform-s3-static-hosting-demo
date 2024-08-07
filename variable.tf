variable "bucketname" {
    default = "vijay-terraform-bucket1"
}

variable "vpcidr" {
    default ="10.1.0.0/16"
  
}
#subnet1cidr
variable "subnetcidr" {
    default = "10.1.1.0/28"
  
}
#subnet2cidr
variable "subnet2cidr" {

    default = "10.1.2.0/24"
  
}

variable "awsami" {
    default = "ami-04a81a99f5ec58529"
  
}
variable "nginxserverami" {
    default = "ami-0ae8f15ae66fe8cda"
  
}

variable "instancetype" {
  description = "The EC2 instance type"
  type        = string
  default     = "t2.micro"

  validation {
    condition     = contains(["t2.micro", "t2.medium", "t2.large"], var.instancetype)
    error_message = "The instance type must be one of the following: t2.micro, t2.medium, t2.large"
  }
}


variable "nginxserver" {
    default = "t2.micro"
  
}
