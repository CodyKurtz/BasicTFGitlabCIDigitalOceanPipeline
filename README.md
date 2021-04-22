# Basic Terraform, Gitlab CI, Ansible Digital Ocean Deployment Pipeline

## Prerequisites:

1. Add 2 Envionrment Varibles to GitLab CI:
   * SSH_PRIVATE_KEY - SSH private key.
   * TF_VAR_api_token - DigitalOcean API Token.
2. Public key needs to be uploaded to DigitalOcean. See variables.tf
3. Certificate and private key also uploaded to DigitalOcean. See data.TF