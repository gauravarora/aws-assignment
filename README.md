# AWS Assignment

**Table of Contents**
* [Built using](#built-using)
* [Access](#access)
* [Installation](#installation)
  * [Terraform infra](#terraform-infra)
  * [Ansible infra](#ansible-infra)
* [Implementation](#implementation)
  * [Terraform](#terraform)
  * [Ansible](#ansible)
* [Architecture](#architecture)
* [Improvements](#improvements)
* [Gotchas](#gotchas)

  
# Built using

* Ansible (v2.5.3)
* Terraform (v0.11.7)

---

# Access

**Replace `domain.com` with the domain provided in the email.**
**Replace `distribution` with the cloudfront distribution id the email.**

* Linux direct access - `http://linux.domain.com`
* Windows direct access - `http://windows.domain.com`
* Access via ALB - `https://aws.domain.com`
* S3 direct access - `https://s3-ap-southeast-1.amazonaws.com/aws-assignment.domain.com/linux-screenshot1.png`
* Cloudfront direct access - `https://distribution.cloudfront.net/linux-screenshot1.png`
* Cloudfront access via domain - `https://cdn.domain.com/linux-screenshot1.png`

---

# Installation
## Terraform infra

* `terraform init`
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

# Architecture
![architecture](https://raw.githubusercontent.com/gauravarora/aws-assignment/master/architecture.png "Architecture diagram")

---

# Improvements
* Link terraform and ansible so the host entries don't have to be updated manually in ansible `hosts`
* Discover ACM certificate in terraform for Cloudfront distribution automatically
* Use a `variables.tf` file for terraform variables so they are centralised
* Move EC2 instances to a private subnet
* Use a NAT gateway for S3/Cloudfront access from EC2 instances
* Use a bastion/jump host for ssh into the linux instance and rdp/winrm into the Windows instance (using port forwarding)
* Use A alias records for EC2 hostnames in route53
* Firgure out how to setup Windows password from terraform (just refuses to work right now)
* Use a apache role in ansible apache playbook to follow best practices
* ~Diagram explaining the architecture~

---

# Gotchas
1. for error on mac
On Mac run
`export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES` to get rid of fork() errors on High Sierra ([bug report](https://github.com/ansible/ansible/issues/32499))

2. Ansible is unable to update the IIS website
This seems like an issue with the way IIS works when a site is provisioned. Updating it causes errors and the Windows machine needs to be recreated using `terraform taint aws_instance.windows`
