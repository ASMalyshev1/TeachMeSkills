terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.default_zone
}

# Получаем образ Ubuntu для VM
data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2404-lts-oslogin"
}

# Сеть и подсеть для всех VM
resource "yandex_vpc_network" "default" {
  name = "default-net"
}

resource "yandex_vpc_subnet" "default" {
  name           = "default-subnet"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.default.id
  v4_cidr_blocks = ["10.0.0.0/24"]
}

resource "yandex_compute_instance" "web_portal" {
  name        = "web_portal"
  platform_id = "standard-v2"
  zone        = var.default_zone

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 12
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.default.id
    nat       = true
  }

  metadata = {
    enable-oslogin = true
  }
}

resource "yandex_compute_instance" "ci_gitlab" {
  name        = "ci_gitlab"
  platform_id = "standard-v2"
  zone        = var.default_zone

  resources {
    cores  = 2
    memory = 6
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 18
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.default.id
    nat       = true
  }
  metadata = {
    enable-oslogin = true
  }
}

resource "yandex_compute_instance" "mon_grafana" {
  name        = "mon_grafana"
  platform_id = "standard-v2"
  zone        = var.default_zone

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 16
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.default.id
    nat       = true
  }
  metadata = {
    enable-oslogin = true
  }
}

resource "yandex_compute_instance" "logs_elk" {
  name        = "logs_elk"
  platform_id = "standard-v2"
  zone        = var.default_zone

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 16
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.default.id
    nat       = true
  }
  metadata = {
    enable-oslogin = true
  }
}

# DNS: zone
resource "yandex_dns_zone" "public" {
  name   = "asmalyshev-public-zone"
  zone   = var.public_zone # "asmalyshev.ru."
  public = true
}

resource "yandex_dns_recordset" "pub_portal" {
  zone_id = yandex_dns_zone.public.id
  name    = "${var.name_portal}.${yandex_dns_zone.public.zone}"
  type    = "A"
  ttl     = 120
  data    = [yandex_compute_instance.web_portal.network_interface[0].nat_ip_address]
}

resource "yandex_dns_recordset" "pub_grafana" {
  zone_id = yandex_dns_zone.public.id
  name    = "${var.name_grafana}.${yandex_dns_zone.public.zone}"
  type    = "A"
  ttl     = 120
  data    = [yandex_compute_instance.mon_grafana.network_interface[0].nat_ip_address]
}

resource "yandex_dns_recordset" "pub_gitlab" {
  zone_id = yandex_dns_zone.public.id
  name    = "${var.name_gitlab}.${yandex_dns_zone.public.zone}"
  type    = "A"
  ttl     = 120
  data    = [yandex_compute_instance.ci_gitlab.network_interface[0].nat_ip_address]
}

resource "yandex_dns_recordset" "pub_elk" {
  zone_id = yandex_dns_zone.public.id
  name    = "logs.${yandex_dns_zone.public.zone}"
  type    = "A"
  ttl     = 120
  data    = [yandex_compute_instance.logs_elk.network_interface[0].nat_ip_address]
}
