# Create VPC Network
resource "yandex_vpc_network" "devnet" {
  name = "devnet"
}

# Create VPC Subnet 1
resource "yandex_vpc_subnet" "devsubnet_1" {
  v4_cidr_blocks = ["10.10.0.0/24"]
  zone           = var.zone_id
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

# Firewall
resource "yandex_vpc_security_group" "BASTION" {
  name       = "bastion"
  network_id = yandex_vpc_network.devnet.id

  ingress {
    protocol       = "TCP"
    description    = "ssh"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "web"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "nexus"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 8081
    to_port        = 8082
  }

  egress {
    protocol       = "ANY"
    description    = "from bastion"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}