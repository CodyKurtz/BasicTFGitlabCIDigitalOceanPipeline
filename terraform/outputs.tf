# The Private IPv4 Addresses of the droplets
output "web_servers_private" {
    value = digitalocean_droplet.web.*.ipv4_address_private
}

output "bastion_servers_private" {
    value = digitalocean_droplet.bastion.*.ipv4_address_private
}

output "bastion_servers_public" {
    value = digitalocean_droplet.bastion.*.ipv4_address
}

# The fully qualified domain name of the load balancer
output "web_loadbalancer_fqdn" {
    value = digitalocean_record.web.fqdn
}

# The fully qualified domain name of the bastion host
output "bastion_fqdn" {
    value = digitalocean_record.bastion.fqdn
}