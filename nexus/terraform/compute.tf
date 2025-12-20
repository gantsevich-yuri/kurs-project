data "yandex_compute_image" "dev_image" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance" "vm" {
  name        = "nexus"
  platform_id = "standard-v3"
  zone        = var.zone_id

  resources {
    cores         = 2
    memory        = 4
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
    subnet_id          = yandex_vpc_subnet.devsubnet_1.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.BASTION.id]
  }

  metadata = {
    user-data          = file("./cloud-init.yml")
    serial-port-enable = "1"
  }

  scheduling_policy { preemptible = true }
}
