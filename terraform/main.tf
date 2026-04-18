module "vpc" {
    source = "./modules/vpc"
    
    name = "eks-vpc-1"
    cidr = "10.0.0.0/16"

    azs = ["ap-south-1a" , "ap-south-1b"]

    private_subnets = [ "10.0.1.0/24" , "10.0.2.0/24" ]
    public_subnets = [ "10.0.101.0/24" , "10.0.102.0/24" ]
}

module "eks" {
  source = "./modules/eks"

  cluster_name  = "my-eks-cluster-2"   
  cluster_version = "1.34"

  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  
}

module "storage" {
  source = "./modules/storage"

  bucket_name = "jenish-devops-app-2026"
  table_name  = "my-app-table"
 // bucket_name = var.bucket_name
 // table_name  = var.table_name
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
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ]
        Resource = module.storage.dynamodb_table_arn
        //Resource = "${module.storage.s3_bucket_arn}/*"
        // Resource = "arn:aws:dynamodb:ap-south-1:*:table/my-app-table"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ]
        Resource = "${module.storage.s3_bucket_arn}/*"
        //Resource = "arn:aws:s3:::jenish-devops-app-2026/*"
      },

        {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = module.storage.s3_bucket_arn
       }
    ]
  })
}
/*resource "aws_iam_policy" "backend_policy" {
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
}*/

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