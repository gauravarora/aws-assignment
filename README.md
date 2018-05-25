**Table of Contents**
* [Built using](#built-using)
* [Installation](#installation)
  * [Terraform infra](#terraform-infra)
  * [Ansible infra](#ansible-infra)
* [Implementation](#implementation)
  * [Terraform](#terraform)
  * [Ansible](#ansible)
* [Gotchas](#gotchas)
  
# Built using

* Ansible (v2.5.3)
* Terraform (v0.11.7)

---

# Installation
## Terraform infra

* `terraform plan`
* `terraform apply`

## Ansible Infra
* Update domain information in `hosts` file
* `ansible-playbook apache.yml`
* `ansible-playbook iis.yml`

---

# Implementation
## Terraform
* `aws.tf` - Basic provider information
* `dns.tf` - DNS related configration. Creates Route53 records for the specified domain.
* `load_balance.tf` - Creates an application load balancer, listeners, attaches ACM certificate, appropriate target groups and attaches instances to target groups.
* `security_group.tf` - Creates security group for ingress & egress
* `cdn.tf` - Creates a Cloudfront Distribution
* `network.tf` - Creates VPC, Subnets, EIP's, Internet Gateway, route tables and attached route tables to subnets.
* `instances.tf` - Creates Linux & Windows instances with appropriate EBS volumes attached, user data scripts & security groups.
* `s3.tf` - Creates an S3 bucket with a proper policy and uploads a default `index.html` file to it
* `data/` - Contains template files

## Ansible
* `apache.yml` - Downloads and sets up apache2 server, copies the default `index.html` from a template
* `iis.yml` - Downloads and sets up IIS, sets up a site, copies the  default `index.html` and deletes the default site

---

# Gotchas
1. for error on mac
On Mac run
`export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES` to get rid of fork() errors on High Sierra ([bug report](https://github.com/ansible/ansible/issues/32499))

2. Ansible is unable to update the IIS website
This seems like an issue with the way IIS works when a site is provisioned. Updating it causes errors and the Windows machine needs to be recreated using `terraform taint aws_instance.windows`
