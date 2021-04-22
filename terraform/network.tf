################################################################################
# Create a VPC for isolating our traffic                                       #
################################################################################
resource "digitalocean_vpc" "web"{
    # The human friendly name of our VPC.
    name = "${local.app_name}-vpc"

    # The region to deploy our VPC to.
    region = var.region
}