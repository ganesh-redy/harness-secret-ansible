provider "google" {
  zone    = var.zone
  project = var.project_id
}

provider "harness" {
  endpoint         = "https://app.harness.io/gateway"
  account_id       = "0PhQdAcEQcCLXQFhDptS_g"
  platform_api_key = "sat.0PhQdAcEQcCLXQFhDptS_g.681e003da4d5d55da387c92f.37YxBP1egpvz0inOysei"
}


terraform {
  required_providers {
    harness = {
      source = "harness/harness"
    }
  }
}

resource "tls_private_key" "my_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "google_compute_instance" "instance0" {
  name         = var.name
  machine_type = var.machine_type

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    ssh-keys = "ansible:${tls_private_key.my_ssh_key.public_key_openssh}"
  }
}

output "vm_external_ip" {
  value = google_compute_instance.instance0.network_interface[0].access_config[0].nat_ip
}

resource "harness_platform_secret_text" "inline" {
  identifier                = "private-key-ansible"
  name                      = "private-key-ansible"
  description               = "terraform create the private key and store in the secrets of harness"
  tags                      = ["foo:bar"]
  secret_manager_identifier = "harnessSecretManager"
  value_type                = "Inline"
  value                     = tls_private_key.my_ssh_key.private_key_pem
}
