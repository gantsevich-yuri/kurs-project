locals {
  instances = {
    app1 = {
      zone = "ru-central1-a"
      cidr = "10.0.1.0/24"
      role = "wan"
    }
    app2 = {
      zone = "ru-central1-b"
      cidr = "10.0.2.0/24"
      role = "wan"
    }
    prometheus = {
      zone = "ru-central1-a"
      cidr = "10.0.1.0/24"
      role = "lan"
    }
    grafana = {
      zone = "ru-central1-a"
      cidr = "10.0.1.0/24"
      role = "wan"
    }
  }
  role_config = {
    wan = {
      nat = true
      sg  = yandex_vpc_security_group.WAN.id
    }
    lan = {
      nat = false
      sg  = yandex_vpc_security_group.LAN.id
    }
  }
}

variable "cloud_id" {
  type = string
}
variable "folder_id" {
  type = string
}