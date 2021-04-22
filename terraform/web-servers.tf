################################################################################
# Create n web servers with nginx installed and a custom message on main page  #
################################################################################
resource "digitalocean_droplet" "web" {
    # How many droplet(s) do we want. Taken from our variables
    count = var.droplet_count

    # public access will be through LB
    private_networking = true

    # Which image to use. Taken from our variables
    image = var.image

    # The human friendly name of our droplet. Combination of web, region, and 
    # count index. 
    name = "${local.app_name}-${var.region}-web-${count.index +1}"

    # What region to deploy the droplet(s) to. Taken from our variables
    region = var.region

    # What size droplet(s) do I want? Taken from our variables
    size = var.droplet_size

    # The ssh keys to put on the server so we can access it. Read in through a 
    # data source
    ssh_keys = [data.digitalocean_ssh_key.main.id]

    # What VPC to put our droplets in
    vpc_uuid = digitalocean_vpc.web.id

    # Tags for identifying the droplets and allowing db firewall access
    tags = [local.app_name, var.env]

    #-----------------------------------------------------------------------------------------------#
    # Ensures that we create the new resource before we destroy the old one                         #
    # https://www.terraform.io/docs/configuration/resources.html#lifecycle-lifecycle-customizations #
    #-----------------------------------------------------------------------------------------------#
    lifecycle {
        create_before_destroy = true
    }
}

################################################################################
# Load Balancer for distributing traffic amongst our web servers. Uses SSL     #
# termination and forwards HTTPS traffic to HTTP internally                    #
################################################################################
resource "digitalocean_loadbalancer" "web" {

    # The user friendly name of the load balancer
    name = "${local.app_name}-web-lb"

    # What region to deploy the LB to
    region = var.region

    # Which droplets should the load balancer route traffic to
    droplet_ids = digitalocean_droplet.web.*.id

    # What VPC to put the load balancer in
    vpc_uuid = digitalocean_vpc.web.id

    # Force all HTTP traffic to come through via HTTPS
    redirect_http_to_https = true
    
    #--------------------------------------------------------------------------#
    # Forward all traffic received on port 443 using the http protocol to       #
    # Port 80 using the http protocol of the hosts behind this load balancer   #
    #--------------------------------------------------------------------------#
    forwarding_rule {
        entry_port = 443
        entry_protocol = "https"

        target_port = 80
        target_protocol = "http"

        certificate_name= data.digitalocean_certificate.web.name
    }

    forwarding_rule {
        entry_port = 80
        entry_protocol = "http"

        target_port = 80
        target_protocol = "http"

        certificate_name = data.digitalocean_certificate.web.name
    }

    #-----------------------------------------------------------------------------------------------#
    # Ensures that we create the new resource before we destroy the old one                         #
    # https://www.terraform.io/docs/configuration/resources.html#lifecycle-lifecycle-customizations #
    #-----------------------------------------------------------------------------------------------#
    lifecycle {
        create_before_destroy = true
    }
}

################################################################################
# Firewall Rules for our Webserver Droplets                                    #
################################################################################
resource "digitalocean_firewall" "web" {

    # The name we give our firewall for ease of use                            #    
    name = "${local.app_name}-firewall"

    # The droplets to apply this firewall to                                   #
    droplet_ids = digitalocean_droplet.web.*.id

    #--------------------------------------------------------------------------#
    # Internal VPC Rules. We have to let ourselves talk to each other          #
    #--------------------------------------------------------------------------#
    inbound_rule {
        protocol = "tcp"
        port_range = "1-65535"
        source_addresses = [digitalocean_vpc.web.ip_range]
    }

    inbound_rule {
        protocol = "udp"
        port_range = "1-65535"
        source_addresses = [digitalocean_vpc.web.ip_range]
    }

    inbound_rule {
        protocol = "icmp"
        source_addresses = [digitalocean_vpc.web.ip_range]
    }

    outbound_rule {
        protocol = "udp"
        port_range = "1-65535"
        destination_addresses = [digitalocean_vpc.web.ip_range]
    }

    outbound_rule {
        protocol = "tcp"
        port_range = "1-65535"
        destination_addresses = [digitalocean_vpc.web.ip_range]
    }

    outbound_rule {
        protocol = "icmp"
        destination_addresses = [digitalocean_vpc.web.ip_range]
    }

    #--------------------------------------------------------------------------#
    # Selective Outbound Traffic Rules                                         #
    #--------------------------------------------------------------------------#

    # DNS
    outbound_rule {
        protocol = "udp"
        port_range = "53"
        destination_addresses = ["0.0.0.0/0", "::/0"]
    }

    # HTTP
    outbound_rule {
        protocol = "tcp"
        port_range = "80"
        destination_addresses = ["0.0.0.0/0", "::/0"]
    }

    # HTTPS
    outbound_rule {
        protocol = "tcp"
        port_range = "443"
        destination_addresses = ["0.0.0.0/0", "::/0"]
    }

    # ICMP (Ping)
    outbound_rule {
        protocol              = "icmp"
        destination_addresses = ["0.0.0.0/0", "::/0"]
    }
}

################################################################################
# Create a DNS A record for our loadbalancer. The name will be the region we   #
# chose.                                                                       #
################################################################################
resource "digitalocean_record" "web" {

    # Get the domain from our data source
    domain = data.digitalocean_domain.web.name

    # An A record is an IPv4 name record. Like www.digitalocean.com
    type   = "A"

    # Set the name to the region we chose. Can be anything
    name   = var.subdomain

    # Point the record at the IP address of our load balancer
    value  = digitalocean_loadbalancer.web.ip

    # The Time-to-Live for this record is 30 seconds. Then the cache invalidates
    ttl    = 300
}
