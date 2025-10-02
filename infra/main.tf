module "cluster" {
  source = "git::https://github.com/henrypham67/istio.git//modules/eks?ref=main"

  name     = var.cluster_name
  vpc_cidr = "10.1.0.0/16"

  desired_nodes = 5
  max_nodes     = 9
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
  chart            = "argocd-apps"
  name             = "appset"
  repository       = "https://argoproj.github.io/argo-helm"
  namespace        = var.argocd_namespace
  create_namespace = true

  values = [file("values/values.yaml")]
}