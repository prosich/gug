# ============================================================================
# Cargar Google Cloud provider para Terraform
# ============================================================================
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# ============================================================================
# Indicar ID de proyecto Google Cloud.
# ============================================================================
# Previamente se debe haber hecho:
# - Crear proyecto prgratis-paco en GC console GUI.
# - Desde shell:
#   gcloud services enable compute.googleapis.com --project="prgratis-paco"

provider "google" {
  project = "prgratis-paco"
}

# ============================================================================
# Crear nuestra maquina llamada "gug" 
# ============================================================================
# Para que sea gratuita debe cumplir:
#   - tipo "e2-micro"
#   - limitado a ciertas zonas, como "us-west1-c"
#   - disco max. 30GB de tipo "pd-standard"
# Creamos un usuario llamado "suser" y le añadimos la clave publica SSH local.

resource "google_compute_instance" "vmgratis" {
  name = "gug"
  machine_type = "e2-micro"
  zone = "us-west1-c"
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
      type  = "pd-standard"
      size  = 20
    }
  }
  network_interface {
    network = "default"
    access_config {
    }
  }
  metadata = {
    ssh-keys = "suser:${file("~/.ssh/id_rsa.pub")}"
  }
}

# ============================================================================
# Mostar dir. IP asignada a la maquina. 
# ============================================================================
output "vm_external_ip" {
  value = google_compute_instance.vmgratis.network_interface[0].access_config[0].nat_ip
}

