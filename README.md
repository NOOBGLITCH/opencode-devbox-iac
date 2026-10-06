# opencode-devbox-iac

⚡ **Automated 1-click cloud devbox for OpenCode & OpenChamber using Terraform and Ansible.**  
Engineered for speed and low overhead on an AWS `c7i-flex.large` instance, powered by Bun, zRAM compressed swap, TCP BBR, and Caddy auto-HTTPS.

---

## Architecture Overview

```
                          Internet / Browser
                                  │
                       Port 443 (HTTPS) / 80 (HTTP)
                                  │
                    ┌─────────────▼─────────────┐
                    │      Caddy Web Server     │  (Auto-TLS via sslip.io)
                    └─────────────┬─────────────┘
                                  │ Reverse Proxy (127.0.0.1:8080)
                    ┌─────────────▼─────────────┐
                    │    OpenChamber Web UI     │  (Systemd User Service)
                    │     & OpenCode Engine     │  (Powered by Bun runtime)
                    └───────────────────────────┘
                                  │
         ┌────────────────────────┼────────────────────────┐
         ▼                        ▼                        ▼
  OpenCode v2 CLI           Wrangler CLI             Caveman CLI
  (AI Coding Agent)    (Cloudflare Workers/Pages)   (Token Optimizer)
```

### Stack Components

| Layer | Technology | Purpose |
|---|---|---|
| **Cloud Provider** | AWS (`ap-south-1`) | Default region in Mumbai; cost-effective compute |
| **Compute** | EC2 `c7i-flex.large` | Intel Emerald Rapids, 2 vCPU, 4 GB RAM, 50 GB gp3 SSD |
| **Network & Security** | VPC, IGW, Security Group | Inbound ports 22 (SSH), 80 (HTTP ACME), 443 (HTTPS) |
| **OS** | Ubuntu 24.04 LTS (Noble) | Modern kernel with native zRAM & BBR support |
| **Memory Optimization**| zRAM (zstd) + Sysctl | 4 GB compressed swap (1:1 RAM ratio) for memory elasticity |
| **Network Optimization**| TCP BBR + `fq` | High-throughput, low-latency networking for remote sessions |
| **Runtime** | Bun | Ultra-fast JavaScript runtime replacing Node.js overhead |
| **Developer Tools** | OpenCode v2, Wrangler, Caveman | Terminal & web agent toolchain pre-installed |
| **Reverse Proxy** | Caddy | Zero-config automatic TLS using wildcard `sslip.io` hostnames |
| **CI/CD** | GitHub Actions | 1-click declarative provisioning and playbook orchestration |

---

## Directory Structure

```
opencode-devbox-iac/
├── .github/
│   └── workflows/
│       └── workflow.yml        # GitHub Actions CI/CD deployment pipeline
├── Terraform/
│   ├── backend.tf              # S3 remote state bucket configuration
│   ├── data.tf                 # AMI filters (Ubuntu 24.04) & IAM policy docs
│   ├── iam.tf                  # Dedicated IAM user and policy attachment
│   ├── main.tf                 # VPC, Subnet, Route Table, SG, EC2 instance
│   ├── outputs.tf              # Instance IP, sslip.io HTTPS URL, IAM keys
│   ├── provider.tf             # HashiCorp AWS provider declaration
│   └── variable.tf             # AWS region, instance type, disk size, key pair
├── ansible/
│   └── playbook.yml            # Machine configuration & service setup
└── README.md
```

---

## Key Features

### 1. Kernel & Memory Tuning (zRAM + BBR)
- **zRAM**: Configures `/etc/systemd/zram-generator.conf` with `zstd` compression, effectively doubling usable memory without slow disk swapping.
- **TCP BBR**: Enables Google's BBR congestion control algorithm (`net.ipv4.tcp_congestion_control = bbr`) and Fair Queueing (`net.core.default_qdisc = fq`).
- **Journal Capping**: Restricts `systemd-journald` to 50 MB to prevent log disk bloat.

### 2. Modern Dev Environment
- **Bun**: Installed to `/usr/local/bin/bun` and `/usr/local/bin/bunx`.
- **OpenCode v2**: Latest native binary installed to `/usr/local/bin/opencode`.
- **OpenChamber Web**: `@openchamber/web` installed globally and run as a persistent user service on port 8080.
- **Cloudflare Wrangler**: Cloudflare development CLI pre-installed.
- **Caveman CLI**: `@caveman-ai/cli` (`caveman`, `cave`) pre-installed for LLM token and cost optimization.

### 3. Zero-Configuration SSL via Caddy & sslip.io
- Caddy automatically provisions Let's Encrypt certificates for `<ip-with-hyphens>.sslip.io` (e.g., `13-233-12-34.sslip.io`).
- Proxies requests to OpenChamber on port 8080 with 600s timeout to support long-running LLM stream generations.

---

## Prerequisites

Before deploying, ensure you have:
1. **AWS Account** with permissions to manage EC2, VPC, IAM, and S3.
2. **S3 Bucket** created for Terraform remote state (named `terraformansiblecicd` in `ap-south-1` by default, or modify [Terraform/backend.tf](file:///home/edith/Desktop/teraformanscid/opencode-devbox-iac/Terraform/backend.tf)).
3. **AWS EC2 Key Pair** created in your target region (default name: `devbox-key`, or configure via `key_name` variable).
4. **GitHub Secrets** configured in your repository (for CI/CD deployment):
   - `AWS_ACCESS_KEY_ID`: IAM user access key.
   - `AWS_SECRET_ACCESS_KEY`: IAM user secret key.
   - `SSH_PRIVATE_KEY`: Private SSH key matching your AWS Key Pair (`devbox-key`).
   - `OPENCHAMBER_PASSWORD`: Password for authenticating into the OpenChamber Web UI.

---

## Deployment Options

### Option A: Automated CI/CD (GitHub Actions)

1. Push your changes to the `main` branch or navigate to **Actions** > **Deploy OpenChamber Devbox** > **Run workflow**.
2. The workflow automatically:
   - Configures AWS credentials.
   - Executes `terraform apply` to provision VPC, networking, and the EC2 instance.
   - Polls port 22 until the instance is reachable via SSH.
   - Injects SSH credentials and runs `ansible-playbook`.
   - Outputs the HTTPS access URL at the end of the run.

### Option B: Manual Local Deployment

#### Step 1: Provision Infrastructure with Terraform
```bash
cd Terraform
terraform init
terraform plan
terraform apply
```

Note the outputs:
- `ec2_public_ip`: Public IPv4 address.
- `devbox_domain`: HTTPS access URL (e.g., `https://13-233-12-34.sslip.io`).

#### Step 2: Configure System with Ansible
```bash
cd ../ansible

# Export public IP and password
export EC2_IP="<your-ec2-public-ip>"
export OPENCHAMBER_PASSWORD="<your-secure-password>"

ansible-playbook -i "${EC2_IP}," \
  -u ubuntu \
  --private-key ~/.ssh/devbox-key.pem \
  --extra-vars "domain_name=${EC2_IP//./-}.sslip.io openchamber_password=${OPENCHAMBER_PASSWORD}" \
  playbook.yml
```

---

## Accessing OpenChamber

Once deployment completes:
1. Open the output domain in your browser:
   ```
   https://<ip-with-hyphens>.sslip.io
   ```
2. Log in using the password configured via `OPENCHAMBER_PASSWORD`.
3. Start building with OpenCode v2 in the browser or connect via SSH:
   ```bash
   ssh -i ~/.ssh/devbox-key.pem ubuntu@<ec2-public-ip>
   ```

---

## Teardown

To destroy all provisioned AWS resources and avoid ongoing compute charges:

```bash
cd Terraform
terraform destroy -auto-approve
```
