# Get information about existing Compute Image
data "yandex_compute_image" "dev_image" {
  family = "ubuntu-2204-lts"
}

# app1
resource "yandex_compute_instance" "app1" {
  name        = "app1"
  platform_id = "standard-v3"
  zone        = var.zone_id

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

  labels = {
    backup = "snapshot"
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.devsubnet_1.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.LAN.id]
  }

  metadata = {
    user-data          = file("./cloud-init.yml")
    hostname           = "app1"
    serial-port-enable = "1"
  }

  scheduling_policy { preemptible = true }
}

# app2
resource "yandex_compute_instance" "app2" {
  name        = "app2"
  platform_id = "standard-v3"
  zone        = "ru-central1-b"

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
    subnet_id          = yandex_vpc_subnet.devsubnet_2.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.LAN.id]
  }

  metadata = {
    user-data          = file("./cloud-init.yml")
    hostname           = "app2"
    serial-port-enable = "1"
  }

  scheduling_policy { preemptible = true }
}

# prometheus
resource "yandex_compute_instance" "prometheus" {
  name        = "prometheus"
  platform_id = "standard-v3"
  zone        = var.zone_id

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
    subnet_id          = yandex_vpc_subnet.devsubnet_1.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.LAN.id]
  }

  metadata = {
    user-data          = file("./cloud-init.yml")
    hostname           = "prometheus"
    serial-port-enable = "1"
  }

  scheduling_policy { preemptible = true }
}

# elasticsearch
resource "yandex_compute_instance" "elk" {
  name        = "elk"
  platform_id = "standard-v3"
  zone        = var.zone_id

  allow_stopping_for_update = true

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
    nat                = false
    security_group_ids = [yandex_vpc_security_group.LAN.id]
  }

  metadata = {
    user-data          = file("./cloud-init.yml")
    hostname           = "elasticsearch"
    serial-port-enable = "1"
  }

  scheduling_policy { preemptible = true }
}

# grafana
resource "yandex_compute_instance" "grafana" {
  name        = "grafana"
  platform_id = "standard-v3"
  zone        = var.zone_id

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
    subnet_id          = yandex_vpc_subnet.devsubnet_1.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.WAN.id]
  }

  metadata = {
    user-data          = file("./cloud-init.yml")
    hostname           = "grafana"
    serial-port-enable = "1"
  }

  scheduling_policy { preemptible = true }
}

# kibana 
resource "yandex_compute_instance" "kibana" {
  name        = "kibana"
  platform_id = "standard-v3"
  zone        = var.zone_id

  allow_stopping_for_update = true

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
    security_group_ids = [yandex_vpc_security_group.WAN.id]
  }

  metadata = {
    user-data          = file("./cloud-init.yml")
    hostname           = "kibana"
    serial-port-enable = "1"
  }

  scheduling_policy { preemptible = true }
}

# bastion 
resource "yandex_compute_instance" "bastion" {
  name        = "bastion"
  platform_id = "standard-v3"
  zone        = var.zone_id

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
    subnet_id          = yandex_vpc_subnet.devsubnet_1.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.BASTION.id]
  }

  metadata = {
    user-data          = file("./cloud-init.yml")
    hostname           = "bastion"
    serial-port-enable = "1"
  }

  scheduling_policy { preemptible = true }
}