module "eks" {
   source = "terraform-aws-modules/eks/aws"
   version = "~> 21.0"

  name    = var.cluster_name
  kubernetes_version = "1.29"
  
  enable_irsa = true
  


  endpoint_private_access = true
  endpoint_public_access = true

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  enable_cluster_creator_admin_permissions = true

  addons = {
    coredns    = {
            most_recent = true
    }
    kube-proxy = {
            most_recent = true
    }
    vpc-cni    = {
            before_compute = true
            most_recent = true
    }
  }

  eks_managed_node_groups = {
     nodegroup1 = {

      desired_size = 2
      max_size     = 3
      min_size     = 1

      instance_types = ["t3.small"]
      iam_role_additional_policies = {
        AmazonEKS_CNI_Policy = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
      }
    }
  }
}