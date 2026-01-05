# Create VPC Network
resource "yandex_vpc_network" "devnet" {
  name = "devnet"
}

# Create VPC Subnet 1
resource "yandex_vpc_subnet" "devsubnet_1" {
  v4_cidr_blocks = ["10.0.10.0/24"]
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.devnet.id
  route_table_id = yandex_vpc_route_table.devroute.id
}

# Create VPC Subnet 2
resource "yandex_vpc_subnet" "devsubnet_2" {
  v4_cidr_blocks = ["10.0.20.0/24"]
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.devnet.id
  route_table_id = yandex_vpc_route_table.devroute.id
}

# Create VPC Route Table
resource "yandex_vpc_route_table" "devroute" {
  name       = "devroute"
  network_id = yandex_vpc_network.devnet.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.devnet_natgw.id
  }
}

# Create VPC NAT Gateway
resource "yandex_vpc_gateway" "devnet_natgw" {
  name = "devnet-natgw"
  shared_egress_gateway {}
}

# Create target group 
resource "yandex_lb_target_group" "devtg" {
  name = "devnet-target-group"

  target {
    subnet_id = yandex_vpc_subnet.devsubnet_1.id
    address   = yandex_compute_instance.app1.network_interface.0.ip_address
  }

  target {
    subnet_id = yandex_vpc_subnet.devsubnet_2.id
    address   = yandex_compute_instance.app2.network_interface.0.ip_address
  }
}

# Create load balancer
resource "yandex_lb_network_load_balancer" "devnlb" {
  name = "devnet-load-balancer"

  listener {
    name        = "devlistener"
    port        = 8080
    target_port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.devtg.id

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}