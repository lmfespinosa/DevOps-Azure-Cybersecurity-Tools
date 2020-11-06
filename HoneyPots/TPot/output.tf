output "tls_private_key" { value = "${tls_private_key.example_ssh.private_key_pem}" }
output "ip_vm" {
  value = azurerm_public_ip.myterraformpublicip.ip_address
}