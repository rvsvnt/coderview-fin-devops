resource "null_resource" "install_istio" {
  provisioner "local-exec" {
    command = <<EOT
      curl -L https://istio.io/downloadIstio | sh -
      cd istio-*
      export PATH=$PWD/bin:$PATH
      istioctl install --set profile=demo -y
    EOT
  }
}

output "istio_installed" {
  value = "Istio installed in ${var.region}"
}