# Create VPC Network
resource "yandex_vpc_network" "devnet" {
  name = "devnet"
}

# Create VPC Subnets
resource "yandex_vpc_subnet" "devsubnet" {
  for_each       = local.instances
  name           = "subnet-${each.key}"
  network_id     = yandex_vpc_network.devnet.id
  v4_cidr_blocks = [each.value.cidr]
  zone           = each.value.zone
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

  dynamic "target" {
    for_each = yandex_compute_instance.vm
    content {
      subnet_id = yandex_vpc_subnet.devsubnet[target.key].id
      address   = target.value.network_interface.0.ip_address
    }
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