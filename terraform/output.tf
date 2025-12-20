output "instance_external_ip" {
  value = {
    for name, inst in yandex_compute_instance.vm :
    name => inst.network_interface.0.nat_ip_address
  }
}