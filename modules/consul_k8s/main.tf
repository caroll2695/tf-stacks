resource "helm_release" "consul" {
  name       = "${var.project}-consul"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "consul"
  namespace  = "consul"

  set {
    name  = "global.name"
    value = "${var.project}-consul"
  }

  set {
    name  = "ui.enabled"
    value = "true"
  }
}
