variable "debian_major_release" {
  type = object({
    codename = string,
    version  = number
  })
  default = {
    codename = "trixie"
    version  = 13
  }
}

variable "rhel_major_release" {
  type = object({
    version = number
  })
  default = {
    version = 10
  }
}

variable "release_url_patterns" {
  type = map(string)
  default = {
    github    = "https://api.github.com/repos/%s/releases/latest"
    gitlab    = "https://gitlab.com/api/v4/projects/%s/releases/"
    hashicorp = "https://checkpoint-api.hashicorp.com/v1/check/%s"
  }
}

variable "release_metadata_version_selectors" {
  type = map(string)
  default = {
    github    = ".tag_name"
    gitlab    = ".[0].tag_name"
    hashicorp = ".current_version"
  }
}

variable "release_download_url_patterns" {
  type = map(string)
  default = {
    github    = "https://github.com/%s/releases/download/$v/"
    gitlab    = "https://gitlab.com/%s/-/releases/$v/downloads/"
    hashicorp = "https://releases.hashicorp.com/%s/$v/"
    teleport  = "https://cdn.teleport.dev/"
    tailscale = "https://pkgs.tailscale.com/stable/"
  }
}

variable "syspkg_version_overrides" {
  type = map(string)
  default = {
    tailscale = "1.92.1"
  }
}
