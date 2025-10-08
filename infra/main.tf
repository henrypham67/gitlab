module "cluster" {
  source = "git::https://github.com/henrypham67/istio.git//modules/eks?ref=main"

  name     = var.cluster_name
  vpc_cidr = "10.1.0.0/16"

  desired_nodes = 9
  max_nodes     = 9
}

locals {
  apps_need_storage = {
    "gitlab" : [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:GetObjectAttributes",
      "s3:ListMultipartUploadParts",
      "s3:AbortMultipartUpload"
    ],
  }
}

module "storages" {
  for_each = local.apps_need_storage
  source   = "git::https://github.com/henrypham67/istio.git//modules/s3-pod-identity?ref=main"

  # Core configuration
  cluster_name         = module.cluster.cluster_name
  application_name     = each.key
  bucket_name          = "my-${each.key}-bucket-199907060500"
  namespace            = "gitlab"
  service_account_name = "${each.key}-sa"

  # S3 configuration
  enable_versioning = true
  sse_algorithm     = "AES256"

  s3_permissions = each.value

  tags = {
    Application = each.key
    Environment = "production"
    DataType    = "git"
  }
}

resource "helm_release" "argocd" {
  chart            = "argo-cd"
  name             = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  namespace        = var.argocd_namespace
  create_namespace = true

  values = [file("values/argocd.yaml")]
}

resource "helm_release" "appset" {
  depends_on = [ helm_release.argocd ]
  chart            = "argocd-apps"
  name             = "appset"
  repository       = "https://argoproj.github.io/argo-helm"
  namespace        = var.argocd_namespace
  create_namespace = true

  values = [file("values/values.yaml")]
}