locals {
  instances = {
    vm-a = {
      zone = "ru-central1-a"
      cidr = "10.0.1.0/24"
    }
    vm-b = {
      zone = "ru-central1-b"
      cidr = "10.0.2.0/24"
    }
  }
}

variable "cloud_id" {
  type = string
}
variable "folder_id" {
  type = string
}