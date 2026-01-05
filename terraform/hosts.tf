resource "local_file" "ansible_inventory" {
  filename = "../ansible/hosts.ini"
  content  = <<EOT
[VMs]
bastion ansible_host=${yandex_compute_instance.bastion.network_interface.0.nat_ip_address} ansible_user=fox ansible_ssh_private_key_file=~/.ssh/yacloud-home
grafana ansible_host=${yandex_compute_instance.grafana.network_interface.0.nat_ip_address} ansible_user=fox ansible_ssh_private_key_file=~/.ssh/yacloud-home
kibana ansible_host=${yandex_compute_instance.kibana.network_interface.0.nat_ip_address} ansible_user=fox ansible_ssh_private_key_file=~/.ssh/yacloud-home
EOT
}