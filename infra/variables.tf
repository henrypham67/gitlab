variable "cluster_name" {
  type    = string
  default = "my-cluster"
}

variable "git_argocd_repo_url" {
  type    = string
  default = "https://github.com/henrypham67/istio"
}

variable "argocd_namespace" {
  type = string
  default = "argocd"
}