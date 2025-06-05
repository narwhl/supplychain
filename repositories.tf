locals {
  repositories = {
    "docker" = {
      "apt" = {
        "signing_key_url" = "https://download.docker.com/linux/debian/gpg"
        "uris"            = "https://download.docker.com/linux/debian"
        "suites"          = "$RELEASE"
        "components"      = "stable"
      }
      "dnf" = {
        "source" = "https://download.docker.com/linux/centos/docker-ce.repo"
      }
    }
    "gitlab" = {
      "apt" = {
        "signing_key_url" = "https://packages.gitlab.com/runner/gitlab-runner/gpgkey"
        "uris"            = "https://packages.gitlab.com/runner/gitlab-runner/debian"
        "suites"          = "$RELEASE"
        "components"      = "main"
      }
      "dnf" = {
        "source" = "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/config_file.repo?os=alma&dist=${var.rhel_major_release.version}&source=script"
      }
    }
    "google-cloud-sdk" = {
      "apt" = {
        "signing_key_url" = "https://packages.cloud.google.com/apt/doc/apt-key.gpg"
        "uris"            = "https://packages.cloud.google.com/apt"
        "suites"          = "cloud-sdk"
        "components"      = "main"
      }
      "dnf" = {
        "source" = "https://artifact.narwhl.dev/upstream/google-cloud-sdk.repo"
      }
    }
    "grafana" = {
      "apt" = {
        "signing_key_url" = "https://apt.grafana.com/gpg.key"
        "uris"            = "https://apt.grafana.com"
        "suites"          = "stable"
        "components"      = "main"
      }
      "dnf" = {
        "source" = "https://artifact.narwhl.dev/upstream/grafana.repo"
      }
    }
    "hashicorp" = {
      "apt" = {
        "signing_key_url" = "https://apt.releases.hashicorp.com/gpg"
        "uris"            = "https://apt.releases.hashicorp.com"
        "suites"          = "$RELEASE"
        "components"      = "main"
      }
      "dnf" = {
        "source" = "https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo"
      }
    }
    "microsoft" = {
      "apt" = {
        "signing_key_url" = "https://packages.microsoft.com/keys/microsoft.asc"
        "uris"            = "https://packages.microsoft.com/repos/azure-cli/"
        "suites"          = "$RELEASE"
        "components"      = "main"
      }
      "dnf" = {
        "source" = "https://packages.microsoft.com/config/rhel/${var.rhel_major_release.version}.0/prod.repo"
      }
    }
    "nvidia-container-toolkit" = {
      "apt" = {
        "signing_key_url" = "https://nvidia.github.io/libnvidia-container/gpgkey"
        "uris"            = "https://nvidia.github.io/libnvidia-container/stable/deb/amd64"
        "suites"          = "/"
      }
      "dnf" = {
        "source" = "https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo"
      }
    }
    "tailscale" = {
      "apt" = {
        "signing_key_url" = "https://pkgs.tailscale.com/stable/debian/${var.debian_major_release.codename}.gpg"
        "uris"            = "https://pkgs.tailscale.com/stable/debian"
        "suites"          = "$RELEASE"
        "components"      = "main"
      }
      "dnf" = {
        "source" = "https://pkgs.tailscale.com/stable/centos/${var.rhel_major_release.version}/tailscale.repo"
      }
    }
  }
}
