resource "terraform_data" "upstream" {
  input = {
    repositories = {
      /* 
      * cloud-init takes keyid in its apt sources section for repository that requires gpg signature
      * it extracts gpg key and outputs its fingerprint string by using an external provider and shorten
      * it to the last 16 characters as keyid
      */
      for publisher, repository in local.repositories : publisher => {
        apt = {
          keyid           = substr(data.external.apt_key[publisher].result.keyid, -16, -1)
          source          = repository.apt.source
          signing_key_url = repository.apt.signing_key_url
        }
        dnf = {
          source = repository.dnf.source
        }
      }
    }
    distros = {
      alma = {
        version = local.distros.alma.version
        iso = {
          url = format(
            "https://repo.almalinux.org/almalinux/%[1]s/isos/x86_64/AlmaLinux-%[1]s-latest-x86_64-minimal.iso",
            split(".", local.distros.alma.version)[0]
          )
          checksum = local.distros.alma.checksums.iso
        }
        qemu = {
          url = format(
            "https://repo.almalinux.org/almalinux/%[1]s/cloud/x86_64/images/AlmaLinux-%[1]s-GenericCloud-latest.x86_64.qcow2",
            split(".", local.distros.alma.version)[0]
          )
          checksum = local.distros.alma.checksums.qemu
        }
      }
      debian = {
        version = local.distros.debian.version
        iso = {
          url = format(
            "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/%s",
            local.distros.debian.iso_filename
          )
          checksum = local.distros.debian.checksums.iso
        }
        qemu = {
          url = format(
            "https://cloud.debian.org/images/cloud/%s/latest/debian-%s-nocloud-amd64.qcow2",
            var.debian_major_release.codename,
            var.debian_major_release.version
          )
          checksum = local.distros.debian.checksums.qemu
        }
      }
      flatcar = {
        version = local.distros.flatcar.version
        ova = {
          url      = "https://stable.release.flatcar-linux.net/amd64-usr/${local.distros.flatcar.version}/flatcar_production_vmware_ova.ova"
          checksum = local.distros.flatcar.checksums.ova
        }
        qemu = {
          url      = "https://stable.release.flatcar-linux.net/amd64-usr/${local.distros.flatcar.version}/flatcar_production_qemu_image.img"
          checksum = local.distros.flatcar.checksums.qemu
        }
      }
      nixos = {
        version = local.distros.nixos.version
        iso = {
          url = format(
            "https://releases.nixos.org/nixos/%[1]s/nixos-%[2]s/nixos-minimal-%[2]s-x86_64-linux.iso",
            local.distros.nixos.channel,
            local.distros.nixos.version
          )
          checksum = local.distros.nixos.checksum
        }
      }
      talos = {
        version = local.distros.talos.version
        iso = {
          url = format(
            "https://github.com/siderolabs/talos/releases/download/${local.distros.talos.version}/metal-amd64.iso"
          )
          checksum = local.distros.talos.checksums.iso
        }
        ova = {
          url = format(
            "https://github.com/siderolabs/talos/releases/download/${local.distros.talos.version}/vmware-amd64.ova"
          )
          checksum = local.distros.talos.checksums.ova
        }
      }
    }
    syspkgs = {
      for name, release_spec in local.pkgs : name => {
        version = trimprefix(
          local.version_of[name],
          "v"
        )
        /*
        * each package has its own download url pattern and filename pattern
        * that is named associated with its version, it checks for package artifact provider's 
        * url pattern and format its url with {org_name/pkg_name} if needed and replaces custom
        * template string with version tag
        */
        pkg_url = release_spec.file_served_by == "hashicorp" ? replace(
          "${strcontains(
            var.release_download_url_patterns[release_spec.file_served_by],
            "%s"
          ) ? format(var.release_download_url_patterns[release_spec.file_served_by], release_spec.release_key) : var.release_download_url_patterns[release_spec.file_served_by]}${release_spec.filename_pattern}",
          "$v",
          release_spec.version_only ? trimprefix(local.version_of[name], "v") : local.version_of[name]
          ) : replace(
          "${strcontains(
            var.release_download_url_patterns[release_spec.file_served_by],
            "%s"
          ) ? format(var.release_download_url_patterns[release_spec.file_served_by], release_spec.release_key) : var.release_download_url_patterns[release_spec.file_served_by]}${replace(release_spec.filename_pattern, "$v", release_spec.version_only ? trimprefix(local.version_of[name], "v") : local.version_of[name])}",
          "$v",
          local.version_of[name]
        )
        filename = replace(
          /* as some vendor allow their asset download path to contain abitrary prefix,
           * filename_pattern need to allow prefix to cope with that, hence it needs to
           * trimmed before setting filename to avoid filesystem error when being saved to after downloading
           */
          element(split("/", release_spec.filename_pattern), length(split("/", release_spec.filename_pattern)) - 1),
          "$v",
          release_spec.version_only ? trimprefix(local.version_of[name], "v") : local.version_of[name]
        )
      }
    }
  }
}

output "state" {
  value = terraform_data.upstream.input
}

output "google_cloud_sdk_repo" {
  value = <<-EOF
    [google-cloud-cli]
    name=Google Cloud CLI
    baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el8-x86_64
    enabled=1
    gpgcheck=1
    repo_gpgcheck=0
    gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
  EOF
}

output "grafana_repo" {
  value = <<-EOF
    [grafana]
    name=grafana
    baseurl=https://rpm.grafana.com
    repo_gpgcheck=1
    enabled=1
    gpgcheck=1
    gpgkey=https://rpm.grafana.com/gpg.key
    sslverify=1
    sslcacert=/etc/pki/tls/certs/ca-bundle.crt
  EOF
}
