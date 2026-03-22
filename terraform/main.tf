module "vpc" {
    source = "./modules/vpc"
    
    name = "eks-vpc"
    cidr = "10.0.0.0/16"

    azs = ["ap-south-1a" , "ap-south-1b"]

    private_subnets = [ "10.0.1.0/24" , "10.0.2.0/24" ]
    public_subnets = [ "10.0.101.0/24" , "10.0.102.0/24" ]
}

module "eks" {
  source = "./modules/eks"

  cluster_name  = "my-eks-cluster"   
  cluster_version = "1.29"

  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets


}