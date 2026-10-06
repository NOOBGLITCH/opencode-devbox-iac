# 1. VPC + Internet Gateway
resource "aws_vpc" "devbox_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name      = "openchamber-vpc"
    ManagedBy = "terraform"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.devbox_vpc.id

  tags = {
    Name = "openchamber-igw"
  }
}

# 2. Public Subnet & Route Table
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.devbox_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"

  tags = {
    Name = "openchamber-public-subnet"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.devbox_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "openchamber-public-rt"
  }
}

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# 3. Security Group (22 SSH, 80 HTTP ACME, 443 HTTPS Web UI)
resource "aws_security_group" "devbox_sg" {
  name        = "openchamber-devbox-sg"
  description = "Allow SSH, HTTP, HTTPS inbound"
  vpc_id      = aws_vpc.devbox_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP ACME challenge"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS OpenChamber Web UI"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "openchamber-devbox-sg"
  }
}

# 4. EC2 Instance (c7i-flex.large)
resource "aws_instance" "devbox" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.devbox_sg.id]
  key_name               = var.key_name

  root_block_device {
    volume_size           = var.volume_size
    volume_type           = "gp3"
    iops                  = 3000
    throughput            = 125
    delete_on_termination = true
  }

  tags = {
    Name = "openchamber-devbox"
  }
}
