locals {
  pkgs = {
    "caddy" = {
      source           = "github"
      repository_id    = "caddyserver/caddy"
      release_key      = "caddyserver/caddy"
      filename_pattern = "caddy_$v_linux_amd64.tar.gz"
      file_served_by   = "github"
      version_only     = true
    }
    "cloudflared" = {
      source           = "github"
      repository_id    = "cloudflare/cloudflared"
      release_key      = "cloudflare/cloudflared"
      filename_pattern = "cloudflared-linux-amd64"
      file_served_by   = "github"
      version_only     = true
    }
    "cni-plugins" = {
      source           = "github"
      repository_id    = "containernetworking/plugins"
      release_key      = "containernetworking/plugins"
      filename_pattern = "cni-plugins-linux-amd64-$v.tgz"
      file_served_by   = "github"
      version_only     = false
    }
    "coredns" = {
      source           = "github"
      repository_id    = "coredns/coredns"
      release_key      = "coredns/coredns"
      filename_pattern = "coredns_$v_linux_amd64.tgz"
      file_served_by   = "github"
      version_only     = true
    }
    "etcd" = {
      source           = "github"
      repository_id    = "etcd-io/etcd"
      release_key      = "etcd-io/etcd"
      filename_pattern = "etcd-$v-linux-amd64.tar.gz"
      file_served_by   = "github"
      version_only     = false
    }
    "gitlab-runner" = {
      source           = "gitlab"
      repository_id    = "250833"
      release_key      = "gitlab-org/gitlab-runner"
      filename_pattern = "binaries/gitlab-runner-linux-amd64"
      file_served_by   = "gitlab"
      version_only     = false
    }
    "lego" = {
      source           = "github"
      repository_id    = "go-acme/lego"
      release_key      = "go-acme/lego"
      filename_pattern = "lego_$v_linux_amd64.tar.gz"
      file_served_by   = "github"
      version_only     = false
    }
    "teleport" = {
      source           = "github"
      repository_id    = "gravitational/teleport"
      release_key      = ""
      filename_pattern = "teleport-$v-linux-amd64-bin.tar.gz"
      file_served_by   = "teleport"
      version_only     = false
    }
    "boundary" = {
      source           = "github"
      repository_id    = "hashicorp/boundary"
      release_key      = "boundary"
      filename_pattern = "boundary_$v_linux_amd64.zip"
      file_served_by   = "hashicorp"
      version_only     = true
    }
    "consul-template" = {
      source           = "github"
      repository_id    = "hashicorp/consul-template"
      release_key      = "consul-template"
      filename_pattern = "consul-template_$v_linux_amd64.zip"
      file_served_by   = "hashicorp"
      version_only     = true
    }
    "packer" = {
      source           = "hashicorp"
      repository_id    = "packer"
      release_key      = "packer"
      filename_pattern = "packer_$v_linux_amd64.zip"
      file_served_by   = "hashicorp"
      version_only     = true
    }
    "vault" = {
      source           = "github"
      repository_id    = "hashicorp/vault"
      release_key      = "vault"
      filename_pattern = "vault_$v_linux_amd64.zip"
      file_served_by   = "hashicorp"
      version_only     = true
    }
    "tailscale" = {
      source           = "github"
      repository_id    = "tailscale/tailscale"
      release_key      = ""
      filename_pattern = "tailscale_$v_amd64.tgz"
      file_served_by   = "tailscale"
      version_only     = true
    }
    "terraform" = {
      source           = "hashicorp"
      repository_id    = "terraform"
      release_key      = "terraform"
      filename_pattern = "terraform_$v_linux_amd64.zip"
      file_served_by   = "hashicorp"
      version_only     = true
    }
    "traefik" = {
      source           = "github"
      repository_id    = "traefik/traefik"
      release_key      = "traefik/traefik"
      filename_pattern = "traefik_$v_linux_amd64.tar.gz"
      file_served_by   = "github"
      version_only     = false
    }
    "sops" = {
      source           = "github"
      repository_id    = "getsops/sops"
      release_key      = "getsops/sops"
      filename_pattern = "sops-$v.linux.amd64"
      file_served_by   = "github"
      version_only     = false
    }
    "step-ca" = {
      source           = "github"
      repository_id    = "smallstep/certificates"
      release_key      = "smallstep/certificates"
      filename_pattern = "step-ca_linux_$v_amd64.tar.gz"
      file_served_by   = "github"
      version_only     = true
    }
    "step-cli" = {
      source           = "github"
      repository_id    = "smallstep/cli"
      release_key      = "smallstep/cli"
      filename_pattern = "step_linux_$v_amd64.tar.gz"
      file_served_by   = "github"
      version_only     = true
    }
    "consul" = {
      source           = "hashicorp"
      repository_id    = "consul"
      release_key      = "consul"
      filename_pattern = "consul_$v_linux_amd64.zip"
      file_served_by   = "hashicorp"
      version_only     = true
    }
    "nomad" = {
      source           = "hashicorp"
      repository_id    = "nomad"
      release_key      = "nomad"
      filename_pattern = "nomad_$v_linux_amd64.zip"
      file_served_by   = "hashicorp"
      version_only     = true
    }
  }
}

data "http" "releases" {
  for_each = local.pkgs
  url      = format(var.release_url_patterns[each.value.source], each.value.repository_id)

  request_headers = {
    Accept = "application/json"
  }
}

data "external" "extract_version" {
  for_each = local.pkgs
  program = [
    "sh",
    "-c",
    "jq -r '.release_response' | jq -r '${var.release_metadata_version_selectors[each.value.source]}' | jq --raw-input '{\"version\": .}'"
  ]

  query = {
    release_response = data.http.releases[each.key].response_body
  }
}

locals {
  version_of = {
    for name, release_spec in local.pkgs : name => data.external.extract_version[name].result.version
  }
}

