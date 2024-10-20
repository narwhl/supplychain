data "http" "debian_release" {
  for_each = {
    "iso"  = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS"
    "qemu" = "https://cloud.debian.org/images/cloud/${var.debian_major_release.codename}/latest/SHA512SUMS"
  }
  url = each.value
}

data "http" "flatcar_release" {
  for_each = {
    "ova"     = "https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_vmware_ova.ova.DIGESTS"
    "qemu"    = "https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_qemu_image.img.DIGESTS"
    "version" = "https://stable.release.flatcar-linux.net/amd64-usr/current/version.txt"
  }
  url = each.value
}

data "http" "alma_release" {
  for_each = {
    "iso"  = "https://repo.almalinux.org/almalinux/${var.rhel_major_release.version}/isos/x86_64/CHECKSUM"
    "qemu" = "https://repo.almalinux.org/almalinux/${var.rhel_major_release.version}/cloud/x86_64/images/CHECKSUM"
  }

  url = each.value
}

data "http" "nixos_channels" {
  url = "https://monitoring.nixos.org/prometheus/api/v1/query?query=channel_revision"
}

data "http" "nixos_release" {
  url = "https://channels.nixos.org/${local.nixos_channel_revision}/latest-nixos-minimal-x86_64-linux.iso.sha256"
}

data "http" "talos" {
  url = "https://api.github.com/repos/siderolabs/talos/releases/latest"
}

data "http" "talos_qemu_customization" {
  url    = "https://factory.talos.dev/schematics"
  method = "POST"

  request_headers = {
    "Accept"       = "application/json"
    "Content-Type" = "application/octet-stream"
  }

  request_body = yamlencode({
    customization = {
      systemExtensions = {
        officialExtensions = [
          "siderolabs/qemu-guest-agent"
        ]
      }
    }
  })
}

data "http" "talos_vmware_customization" {
  url    = "https://factory.talos.dev/schematics"
  method = "POST"

  request_headers = {
    "Accept"       = "application/json"
    "Content-Type" = "application/octet-stream"
  }

  request_body = yamlencode({
    customization = {
      systemExtensions = {
        officialExtensions = [
          "siderolabs/vmtoolsd-guest-agent"
        ]
      }
    }
  })
}
locals {
  nixos_releases = jsondecode(data.http.nixos_channels.response_body)["data"]["result"]
}

locals {
  nixos_channel_revision = [for release in local.nixos_releases : release.metric.channel if release.metric.status == "stable" && contains(keys(release.metric), "variant") && release.metric.variant == "primary"][0]
  talos_version          = jsondecode(data.http.talos.response_body).tag_name
}

locals {
  distros = {
    alma = {
      version = trimsuffix(
        trimprefix(
          split(":", split("\n", data.http.alma_release["iso"].response_body)[7])[0],
          "# AlmaLinux-"
        ),
        "-x86_64-minimal.iso"
      )
      checksums = {
        iso = split(
          " = ",
          split("\n", data.http.alma_release["iso"].response_body)[8]
        )[1]
        qemu = split(
          "  ",
          split("\n", data.http.alma_release["qemu"].response_body)[1]
        )[0]
      }
    }
    debian = {
      iso_filename = split("  ", split("\n", data.http.debian_release["iso"].response_body)[0])[1]
      version      = trimprefix(trimsuffix(split("  ", split("\n", data.http.debian_release["iso"].response_body)[0])[1], "-amd64-netinst.iso"), "debian-")
      checksums = {
        iso  = split("  ", split("\n", data.http.debian_release["iso"].response_body)[0])[0]
        qemu = split("  ", split("\n", data.http.debian_release["qemu"].response_body)[8])[0]
      }
    }
    flatcar = {
      version = split("=", split("\n", data.http.flatcar_release["version"].response_body)[3])[1]
      checksums = {
        ova  = split("  ", split("\n", data.http.flatcar_release["ova"].response_body)[5])[0]
        qemu = split("  ", split("\n", data.http.flatcar_release["qemu"].response_body)[5])[0]
      }
    }
    nixos = {
      channel  = trimprefix(local.nixos_channel_revision, "nixos-")
      checksum = split("  ", data.http.nixos_release.response_body)[0]
      version  = trimprefix(trimsuffix(split("  ", data.http.nixos_release.response_body)[1], "-x86_64-linux.iso"), "nixos-minimal-")
    }
    talos = {
      version = local.talos_version
    }
  }
}
