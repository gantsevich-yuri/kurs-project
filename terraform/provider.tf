terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.158.0"
    }
  }
}

provider "yandex" {
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  service_account_key_file = file("~/.authorized_key_yacl_worker.json")
  zone                     = "ru-central1-a"
}
