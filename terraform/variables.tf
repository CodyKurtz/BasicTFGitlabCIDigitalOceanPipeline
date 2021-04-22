################################################################################
# Required Variables. These variables have no default and you will be requried #
# to provide them.                                                             #
################################################################################

# Our DigitalOcean API token.
variable api_token {
    type = string
    sensitive = true
}

# Name of your SSH Key as it appears in the DigitalOcean dashboard
variable ssh_key {
    type = string
}

# The first part of my URL. Ex: the www in www.digitalocean.com
variable "subdomain" {
    type = string
}

# Domain you have registered and DigitalOcean manages
variable domain_name {
    type = string
}

# environment (dev or prod)
variable env {
    type = string
}

################################################################################
# Optional Variables. These have defaults set don't need to be modified for    #
# this to run. Modify them to your liking if you desire.terraform              #
################################################################################

# Our DigitalOcean Project
variable project_name {
    type = string
    default = "Demo App"
}

# Name of your project. Will be prepended to most resources
variable "name" {
    type = string
    default = "minimal-vpc"
}
# The region to deploy our infrastructure to.
variable "region" {
    type    = string
    default = "nyc1"
}

# The number of droplets to create.
variable "droplet_count" {
    type = number
    default = 1
}

# The size we want our droplets to be. 
# Can view slugs (valid options) https://slugs.do-api.dev/
variable "droplet_size" {
    type = string
    default = "s-1vcpu-1gb"
}

# The operating system image we want to use. 
# Can view slugs (valid options) https://slugs.do-api.dev/
variable "image" {
    type = string
    default = "ubuntu-20-10-x64"
}

# Local variables
locals {
  # Unique App name based on project name and environment
  app_name = "${var.env}-${var.name}"
}