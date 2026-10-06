# opencode-devbox-iac

⚡ **Automated 1-click cloud development environment using AWS, Terraform, Ansible, and GitHub Actions**

This project automates the complete setup of a cloud-based development environment on AWS. Instead of manually creating infrastructure, configuring a Linux server, installing development tools, setting up services, and configuring HTTPS, the complete process can be triggered through **GitHub Actions**

The devbox runs on an AWS EC2 `c7i-flex.large` instance and includes **Bun, OpenCode, OpenChamber, Cloudflare Wrangler, Caddy, zRAM, and TCP BBR**

The main goal was to build a **repeatable Infrastructure as Code (IaC) workflow** that combines cloud provisioning, configuration management, CI/CD automation, security, Linux administration, and troubleshooting into one deployment process

---

# Architecture Overview

```text
                         Internet / Browser
                                │
                         HTTPS 443 / HTTP 80
                                │
                    ┌───────────▼───────────┐
                    │     Caddy Web Server  │
                    │    Auto HTTPS / TLS   │
                    └───────────┬───────────┘
                                │
                       Reverse Proxy
                       127.0.0.1:8080
                                │
                    ┌───────────▼───────────┐
                    │   OpenChamber Web UI  │
                    │   + OpenCode Engine   │
                    │      Bun Runtime      │
                    └───────────┬───────────┘
                                │
                       /home/ubuntu/workspace
                                │
             ┌──────────────────┼──────────────────┐
             ▼                  ▼                  ▼
       OpenCode v2          Wrangler CLI       Caveman CLI
       AI Coding Agent      Cloudflare Tools   Token Optimizer
```

The architecture uses **Caddy as the reverse proxy**, OpenChamber as the web interface, OpenCode as the coding engine, and a pre-configured workspace for development tools

---

# Tech Stack

| Layer | Technology | Purpose |
|---|---|---|
| Cloud | AWS | Cloud infrastructure |
| Region | `ap-south-1` | AWS Mumbai region |
| Compute | EC2 `c7i-flex.large` | Cloud development server |
| Networking | VPC, IGW, Security Group | Network connectivity and access control |
| IAM | Dedicated IAM User + Policy | Controlled infrastructure access |
| OS | Ubuntu 24.04 LTS | Server operating system |
| IaC | Terraform | Infrastructure provisioning |
| Configuration | Ansible | Server configuration and automation |
| CI/CD | GitHub Actions | Automated deployment pipeline |
| Runtime | Bun | JavaScript runtime |
| Reverse Proxy | Caddy | Reverse proxy and automatic HTTPS |
| Development | OpenCode, OpenChamber | AI development environment |
| Cloud Tools | Wrangler | Cloudflare Workers/Pages CLI |
| Optimization | zRAM + zstd | Memory optimization |
| Networking | TCP BBR + `fq` | Network performance optimization |

These components are combined into a single workflow rather than being used as isolated tools

---

# Project Structure

```text
opencode-devbox-iac/
│
├── .github/
│   └── workflows/
│       └── workflow.yml
│
├── Terraform/
│   ├── backend.tf
│   ├── data.tf
│   ├── iam.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── provider.tf
│   └── variable.tf
│
├── ansible/
│   └── playbook.yml
│
└── README.md
```

## Terraform

```text
backend.tf       → S3 remote state configuration
data.tf          → Ubuntu AMI and IAM policy data
iam.tf           → Dedicated IAM user and policy
main.tf          → VPC, subnet, routing, security group and EC2
outputs.tf       → EC2 IP and deployment outputs
provider.tf      → AWS provider configuration
variable.tf      → Infrastructure variables
```

## Ansible

```text
playbook.yml     → Linux configuration, software installation,
                   system tuning, OpenChamber and Caddy setup
```

The project separates **infrastructure provisioning** from **server configuration**, allowing Terraform and Ansible to handle the areas they are best suited for

---

# Key Features

## 1. Infrastructure as Code with Terraform

AWS infrastructure is defined using Terraform instead of manually creating resources through the AWS Console

The Terraform configuration handles:

- VPC
- Subnet
- Internet Gateway
- Route Table
- Security Group
- EC2 instance
- IAM resources
- S3 remote state

This makes the infrastructure repeatable and easier to maintain

---

## 2. Dedicated IAM Security

The project uses a dedicated IAM user with a scoped infrastructure policy instead of relying directly on the AWS root account

This provides a more controlled approach to deployment access and separates infrastructure operations from the main AWS account

---

## 3. Automated Linux Configuration with Ansible

After Terraform provisions the EC2 instance, Ansible configures the server automatically

The playbook handles:

- Linux system configuration
- Bun installation
- OpenCode installation
- OpenChamber setup
- Workspace initialization
- systemd service configuration
- Caddy installation and configuration
- Kernel and networking optimization

This removes repetitive manual SSH configuration

---

## 4. Memory & Network Optimization

The server is configured with:

- **zRAM** using zstd compression
- **TCP BBR** congestion control
- **Fair Queueing**
- **journald size limits**

These optimizations were added to make better use of the available resources on the lightweight EC2 environment

---

## 5. Ready-to-Use Development Environment

The devbox comes pre-configured with:

- Bun
- OpenCode v2
- OpenChamber Web
- Wrangler CLI
- Caveman CLI
- Git
- Pre-configured workspace
- Persistent systemd service

The idea is simple: **provision the infrastructure and get a usable development environment without repeating the same installation steps manually**

---

## 6. Automatic HTTPS with Caddy

Caddy is used as the reverse proxy in front of OpenChamber

It automatically handles HTTPS using `sslip.io`

Example:

```text
https://<ip-with-hyphens>.sslip.io
```

Requests are forwarded to OpenChamber running locally on:

```text
127.0.0.1:8080
```

This provides a simple way to expose the development environment securely without manually configuring a traditional domain

---

# CI/CD Deployment Workflow

The project uses **GitHub Actions** to automate the complete deployment process

The workflow can be triggered from:

```text
GitHub
  ↓
Actions
  ↓
Deploy OpenChamber Devbox
  ↓
Run workflow
```

It can also be triggered automatically through a configured Git push

### Deployment Flow

```text
GitHub Actions Runner
        │
        ▼
Configure AWS Credentials
        │
        ▼
Check / Create S3 Terraform State
        │
        ▼
Import EC2 SSH Key Pair
        │
        ▼
Terraform Init
        │
        ▼
Terraform Apply
        │
        ▼
Create VPC + EC2
        │
        ▼
Wait for SSH Readiness
        │
        ▼
Run Ansible Playbook
        │
        ├── Linux configuration
        ├── Kernel tuning
        ├── Bun installation
        ├── OpenCode installation
        ├── OpenChamber setup
        ├── Workspace initialization
        └── Caddy configuration
        │
        ▼
Generate HTTPS Access URL
```

The result is a **repeatable, automated cloud deployment workflow** instead of a collection of manual AWS and SSH steps

---

# GitHub Secrets

The workflow uses GitHub Secrets for sensitive deployment information

```text
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
SSH_PRIVATE_KEY
OPENCHAMBER_PASSWORD
```

These secrets are consumed by the GitHub Actions deployment workflow rather than being hardcoded into the repository

---

# Key Learnings

While building this project, I learned that DevOps is not just about writing Terraform or YAML. The real learning came from connecting AWS, Terraform, Ansible, Linux and GitHub Actions together and troubleshooting issues when things didn't work as expected

- **IAM & Security** — Learned how to use dedicated IAM users and scoped policies instead of depending on root access
- **Infrastructure as Code** — Learned how Terraform can make AWS infrastructure repeatable and reduce manual cloud configuration
- **CI/CD Automation** — Learned how to connect GitHub Actions with Terraform and Ansible to automate the complete deployment process
- **Terraform State Management** — Learned how remote state works and how to handle the S3 backend bootstrap problem on a fresh AWS environment
- **Terraform + Ansible** — Understood how Terraform can provision the infrastructure while Ansible handles Linux server configuration
- **Linux Administration** — Got hands-on experience with SSH, systemd, journald, permissions, environment variables, networking and service management
- **Cloud Automation** — Learned how to automate EC2 key-pair provisioning, server readiness checks and application configuration
- **Troubleshooting** — Solved real issues involving Terraform outputs, Ansible inventory, Bun/Node compatibility, `$HOME` permissions and Ubuntu configuration
- **Networking & HTTPS** — Learned how reverse proxying, Caddy, DNS and automatic TLS work together to securely expose a service
- **Infrastructure Optimization** — Worked with zRAM, TCP BBR, Fair Queueing and journald limits to improve the lightweight cloud environment
- **DevOps Mindset** — Learned to think about security, repeatability, reliability, automation and cleanup instead of focusing only on getting the application running

### Biggest Takeaway

**The biggest lesson was that real DevOps work is about making infrastructure reliable and repeatable, while being able to troubleshoot the problems that appear between different tools and systems**

---

# Real Engineering Problems Solved

One of the most valuable parts of this project was dealing with real deployment failures instead of only following a predefined tutorial

## S3 Backend Bootstrap

Terraform requires the S3 backend to exist before the remote state can be initialized

On a fresh AWS environment, this caused the deployment to fail because the bucket was not available

The GitHub Actions workflow was updated to check for the bucket and create it when required before running Terraform initialization

---

## Automatic EC2 Key Pair Provisioning

The EC2 instance required an SSH key pair

Instead of manually creating the key pair in the AWS Console, the workflow derives the public key from the GitHub `SSH_PRIVATE_KEY` secret and imports it into AWS automatically

This removed another manual deployment dependency

---

## Terraform Output Issue

The `hashicorp/setup-terraform` GitHub Action wrapper caused issues when reading Terraform outputs

The workflow was adjusted with:

```yaml
terraform_wrapper: false
```

This allowed commands such as Terraform output retrieval to work correctly inside the pipeline

---

## Ansible Dynamic Inventory

The EC2 host was dynamically passed to Ansible, which placed it in the `all` group

The playbook was originally expecting a `devbox` host group

Changing the playbook target to:

```yaml
hosts: all
```

resolved the inventory mismatch

---

## Ubuntu 24.04 Configuration Issue

The expected `journald.conf.d` directory was not available on the fresh Ubuntu 24.04 environment

The Ansible playbook was updated to create the directory before writing the journald configuration file

---

## Bun / Node Compatibility

Some CLI tools expected the `node` executable through a Node.js shebang even though the environment was designed around Bun

A compatibility symlink was created so tools expecting `node` could execute through Bun

This was a good reminder that replacing one runtime with another can introduce compatibility issues that need to be handled at the system level

---

## Ansible `$HOME` Environment Issue

When running tasks with `become_user: ubuntu`, Bun was still trying to use `/root/.bun`

The task environment was updated with the correct user home directory:

```yaml
environment:
  HOME: /home/ubuntu
```

This resolved the permission issue and allowed user-scoped Bun installation to work correctly

---

## OpenChamber Workspace Initialization

A fresh OpenChamber installation did not have an active project configured

The solution was to:

- Initialize the workspace with Git
- Configure the OpenChamber project settings
- Set the active project
- Configure the systemd service with the correct working directory

This allowed the web interface and related APIs to work correctly after deployment

---

## sslip.io TLS Issue

Using the raw dotted IP as an `sslip.io` hostname created multi-level subdomain and certificate problems

The hostname format was changed from:

```text
65.1.132.72.sslip.io
```

to:

```text
65-1-132-72.sslip.io
```

This provided a cleaner hostname structure for Caddy and Let's Encrypt certificate provisioning

---

# Cleanup

To destroy the Terraform-managed infrastructure:

```bash
cd Terraform
terraform destroy -auto-approve
```

This helps remove the deployed AWS resources and avoid unnecessary infrastructure costs

For manual cleanup:

```bash
aws ec2 terminate-instances \
  --region ap-south-1 \
  --instance-ids <instance-id>

aws s3 rb s3://terraformansiblecicd \
  --force \
  --region ap-south-1
```

---

# Project Outcome

The final workflow connects multiple DevOps tools into one automated deployment pipeline:

```text
                         GitHub Actions
                               │
                               ▼
                           Terraform
                               │
                               ▼
                       AWS Infrastructure
                               │
                     ┌─────────┴─────────┐
                     ▼                   ▼
                    VPC                 EC2
                                         │
                                         ▼
                                     Ansible
                                         │
                         ┌───────────────┼───────────────┐
                         ▼               ▼               ▼
                       Linux         OpenCode       OpenChamber
                    Configuration       │               │
                                        └───────┬───────┘
                                                ▼
                                             Caddy
                                                │
                                                ▼
                                          HTTPS Access
```

The project goes beyond simply launching an EC2 instance. It demonstrates practical experience with:

**Infrastructure as Code • AWS Cloud Infrastructure • Terraform • Ansible • GitHub Actions • CI/CD • IAM • EC2 • VPC • S3 • Linux Administration • SSH • Systemd • Networking • HTTPS • Reverse Proxy • Cloud Automation • Troubleshooting**

The main takeaway from the project was learning how to **design, automate, troubleshoot and maintain a complete cloud infrastructure workflow instead of working with individual DevOps tools in isolation**
