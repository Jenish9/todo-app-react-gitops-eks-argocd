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

module "storage" {
  source = "./modules/storage"

  bucket_name = "jenish-devops-app-2026"
  table_name  = "my-app-table"
  environment = "production"
}

resource "aws_iam_policy" "backend_policy" {
  name = "eks-backend-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*",
          "dynamodb:*"
        ]
        Resource = "*"
      }
    ]
  })
}

data "aws_iam_policy_document" "irsa_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:sub"
      values   = ["system:serviceaccount:default:backend-sa"]
    }
  }
}

resource "aws_iam_role" "backend_role" {
  name = "eks-backend-role"

  assume_role_policy = data.aws_iam_policy_document.irsa_assume_role.json
}

resource "aws_iam_role_policy_attachment" "backend_attach" {
  role       = aws_iam_role.backend_role.name
  policy_arn = aws_iam_policy.backend_policy.arn
}

output "backend_role_arn" {
  value = aws_iam_role.backend_role.arn
}
