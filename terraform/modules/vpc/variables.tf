variable "name" {
    description = "VPC name"
    type = string 
}

variable "cidr" {
    description = "VPC CIDR"
    type = string
}

variable "azs" {
    description = "Availability zone"
    type = list(string) 
}

variable "private_subnets" {
    description = "Private subnate cidrs"
    type = list(string)  
}

variable "public_subnets" {
    description = "Public subnets cidrs"
    type = list(string)  
}