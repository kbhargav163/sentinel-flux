# 1. Define the Global Provider Core Configuration Context
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
}

# 2. Provision a Production-Grade Custom Virtual Private Cloud (VPC)
resource "aws_vpc" "sentinel_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name        = "sentinel-flux-vpc"
    Environment = var.environment_tag
  }
}

# 3. Create a Public Subnet for our Monitoring Telemetry Server
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.sentinel_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "sentinel-public-subnet"
  }
}

# 4. Attach an Internet Gateway to route traffic out to the open web
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.sentinel_vpc.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.sentinel_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# 5. Define an Intelligent Security Group Firewall Configuration Matrix
resource "aws_security_group" "monitoring_sg" {
  name        = "sentinel-monitoring-firewall"
  description = "Controls traffic ingress and egress for the Prometheus stack instances"
  vpc_id      = aws_vpc.sentinel_vpc.id

  # Accept Spring Boot dashboard management metric API traffic
  ingress {
    from_port   = 8085
    to_port     = 8085
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Accept incoming query traffic to the Prometheus web engine interface
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Open communication outbound vector paths so the server can fetch package updates
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 6. Allocate a Dedicated EC2 Virtual Computing Compute Instance Node
resource "aws_instance" "monitoring_server" {
  ami           = "ami-0c7217cdde317cfec" # Canonical Ubuntu Server 22.04 LTS Base Image
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.monitoring_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo docker run -d --name cloud-prometheus -p 9090:9090 ubuntu/prometheus:latest
              EOF

  tags = {
    Name        = "sentinel-telemetry-node"
    Environment = var.environment_tag
  }
}

# 7. Configure Input Variables to Maintain Environment Parity
variable "environment_tag" {
  type        = string
  description = "Target deployment workspace tier parameter"
  default     = "Development"
}

# 8. Output Variables to cleanly expose the provisioned node's IP address
output "monitoring_server_public_ip" {
  value       = aws_instance.monitoring_server.public_ip
  description = "The public IP address assigned to our active telemetry host instance"
}