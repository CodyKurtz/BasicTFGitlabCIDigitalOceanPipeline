resource "digitalocean_project_resources" "projects" {
  project = data.digitalocean_project.project.id
  resources = concat(digitalocean_droplet.web.*.urn, 
        digitalocean_droplet.bastion.*.urn,
        digitalocean_loadbalancer.web.*.urn)
}