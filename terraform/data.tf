data "digitalocean_ssh_key" "main" {
    name = var.ssh_key
}

data "digitalocean_domain" "web" {
    name = var.domain_name
}

data "digitalocean_project" "project" {
    name = var.project_name
}

data "digitalocean_certificate" "web" {
    name = "my-cert"
}