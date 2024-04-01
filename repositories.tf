locals {
  repositories = {
    "docker" = {
      "apt" = {
        "signing_key_url" = "https://download.docker.com/linux/debian/gpg"
        "source"          = "https://download.docker.com/linux/debian $RELEASE stable"
      }
      "dnf" = {
        "source" = "https://download.docker.com/linux/centos/docker-ce.repo"
      }
    }
    "gitlab" = {
      "apt" = {
        "signing_key_url" = "https://packages.gitlab.com/runner/gitlab-runner/gpgkey"
        "source"          = "https://packages.gitlab.com/runner/gitlab-runner/debian $RELEASE main"
      }
      "dnf" = {
        "source" = "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/config_file.repo?os=alma&dist=${var.rhel_major_release.version}&source=script"
      }
    }
    "google-cloud-sdk" = {
      "apt" = {
        "signing_key_url" = "https://packages.cloud.google.com/apt/doc/apt-key.gpg"
        "source"          = "https://packages.cloud.google.com/apt cloud-sdk main"
      }
      "dnf" = {
        "source" = "https://artifact.narwhl.dev/upstream/google-cloud-sdk.repo"
      }
    }
    "grafana" = {
      "apt" = {
        "signing_key_url" = "https://apt.grafana.com/gpg.key"
        "source"          = "https://apt.grafana.com stable main"
      }
      "dnf" = {
        "source" = "https://artifact.narwhl.dev/upstream/grafana.repo"
      }
    }
    "hashicorp" = {
      "apt" = {
        "signing_key_url" = "https://apt.releases.hashicorp.com/gpg"
        "source"          = "https://apt.releases.hashicorp.com $RELEASE main"
      }
      "dnf" = {
        "source" = "https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo"
      }
    }
    "microsoft" = {
      "apt" = {
        "signing_key_url" = "https://packages.microsoft.com/keys/microsoft.asc"
        "source"          = "https://packages.microsoft.com/repos/azure-cli/ $RELEASE main"
      }
      "dnf" = {
        "source" = "https://packages.microsoft.com/config/rhel/9.0/prod.repo"
      }
    }
    "nvidia-container-toolkit" = {
      "apt" = {
        "signing_key_url" = "https://nvidia.github.io/libnvidia-container/gpgkey"
        "source"          = "https://nvidia.github.io/libnvidia-container/stable/deb/amd64 /"
      }
      "dnf" = {
        "source" = "https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo"
      }
    }
    "tailscale" = {
      "apt" = {
        "signing_key_url" = "https://pkgs.tailscale.com/stable/debian/${var.debian_major_release.codename}.noarmor.gpg"
        "source"          = "https://pkgs.tailscale.com/stable/debian $RELEASE main"
      }
      "dnf" = {
        "source" = "https://pkgs.tailscale.com/stable/centos/${var.rhel_major_release.version}/tailscale.repo"
      }
    }
  }
}

data "external" "apt_key" {
  for_each = local.repositories
  program = [
    "sh",
    "-c",
    "wget -qO- $(jq -r '.signing_key_url') | gpg --with-fingerprint --with-colons 2>/dev/null | awk -F: '/^fpr/ { print $10 }' | head -1 | jq --raw-input '{\"keyid\": .}'"
  ]
  query = {
    signing_key_url = each.value.apt.signing_key_url
  }
}
