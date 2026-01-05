resource "local_file" "ansible_inventory" {
  filename = "../ansible/hosts.ini"
  content  = <<EOT
[app]
app1 ansible_host=${yandex_compute_instance.app1.network_interface.0.ip_address} ansible_user=fox ansible_ssh_private_key_file=~/.ssh/yacloud-home ansible_ssh_common_args='-o ProxyJump=fox@${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}'
app2 ansible_host=${yandex_compute_instance.app2.network_interface.0.ip_address} ansible_user=fox ansible_ssh_private_key_file=~/.ssh/yacloud-home ansible_ssh_common_args='-o ProxyJump=fox@${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}'

[other]
bastion ansible_host=${yandex_compute_instance.bastion.network_interface.0.nat_ip_address} ansible_user=fox ansible_ssh_private_key_file=~/.ssh/yacloud-home
grafana ansible_host=${yandex_compute_instance.grafana.network_interface.0.nat_ip_address} ansible_user=fox ansible_ssh_private_key_file=~/.ssh/yacloud-home
kibana ansible_host=${yandex_compute_instance.kibana.network_interface.0.nat_ip_address} ansible_user=fox ansible_ssh_private_key_file=~/.ssh/yacloud-home
prometheus ansible_host=${yandex_compute_instance.prometheus.network_interface.0.ip_address} ansible_user=fox ansible_ssh_private_key_file=~/.ssh/yacloud-home ansible_ssh_common_args='-o ProxyJump=fox@${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}'
elk ansible_host=${yandex_compute_instance.elk.network_interface.0.ip_address} ansible_user=fox ansible_ssh_private_key_file=~/.ssh/yacloud-home ansible_ssh_common_args='-o ProxyJump=fox@${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}'
EOT
}