resource "local_file" "ansible_inventory" {
  filename = "../ansible/hosts.ini"
  content  = <<EOT
[VMs]
app1 ansible_host=${yandex_compute_instance.vm["app1"].network_interface.0.nat_ip_address} ansible_user=fox ansible_ssh_private_key_file=~/.ssh/yacloud-home
app2 ansible_host=${yandex_compute_instance.vm["app2"].network_interface.0.nat_ip_address} ansible_user=fox ansible_ssh_private_key_file=~/.ssh/yacloud-home
EOT
}