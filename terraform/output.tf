output "bastion_external_ip" {
  value = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
}

output "grafana_external_ip" {
  value = yandex_compute_instance.grafana.network_interface[0].nat_ip_address
}

output "kibana_external_ip" {
  value = yandex_compute_instance.kibana.network_interface[0].nat_ip_address
}