# Get information about existing Compute Image
data "yandex_compute_image" "dev_image" {
  family = "ubuntu-2204-lts"
}

# VMs
resource "yandex_compute_instance" "vm" {
  for_each = local.instances

  name        = each.key
  hostname    = each.key
  platform_id = "standard-v3"

  resources {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.dev_image.id
      type     = "network-hdd"
      size     = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.devsubnet[each.key].id
    nat                = true
    # security_group_ids = [yandex_vpc_security_group.WAN.id]
    security_group_ids = [local.security_groups[each.value.role]]
  }

  zone = each.value.zone

  metadata = {
    user-data          = file("./cloud-init.yml")
    serial-port-enable = "1"
  }

  scheduling_policy { preemptible = true }
}