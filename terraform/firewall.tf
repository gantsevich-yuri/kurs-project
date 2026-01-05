resource "yandex_vpc_security_group" "WAN" {
  name       = "wan"
  network_id = yandex_vpc_network.devnet.id

  ingress {
    protocol       = "TCP"
    description    = "web"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "grafana"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 3000
  }

  ingress {
    protocol       = "TCP"
    description    = "kibana"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 5601
  }

  ingress {
    protocol       = "TCP"
    description    = "ssh from internal"
    #v4_cidr_blocks = ["10.0.0.0/16"]
    v4_cidr_blocks = ["0.0.0.0/0"] # add 0/0 for install docker pckg from ansible playbook 
    port           = 22
  }

  egress {
    protocol       = "ANY"
    description    = "from vm"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

resource "yandex_vpc_security_group" "LAN" {
  name       = "lan"
  network_id = yandex_vpc_network.devnet.id

  ingress {
    protocol       = "TCP"
    description    = "ssh from internal"
    v4_cidr_blocks = ["10.0.0.0/16"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "from LB"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "prometheus"
    v4_cidr_blocks = ["10.0.0.0/16"]
    port           = 9090
  }

  ingress {
    protocol       = "TCP"
    description    = "ELK"
    v4_cidr_blocks = ["10.0.0.0/16"]
    port           = 9200
  }

  egress {
    protocol       = "ANY"
    description    = "from lan"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

resource "yandex_vpc_security_group" "BASTION" {
  name       = "bastion"
  network_id = yandex_vpc_network.devnet.id

  ingress {
    protocol       = "TCP"
    description    = "ssh"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  egress {
    protocol       = "ANY"
    description    = "from bastion"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}