# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name      = "${var.project_name}-${var.env}-vpc"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

# Subnet
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name      = "${var.project_name}-${var.env}-subnet-public-${var.region}a"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}


resource "aws_subnet" "public_c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.region}c"
  map_public_ip_on_launch = true

  tags = {
    Name      = "${var.project_name}-${var.env}-subnet-public-${var.region}c"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}


resource "aws_subnet" "protected_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name      = "${var.project_name}-${var.env}-subnet-protected-${var.region}a"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

resource "aws_subnet" "protected_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "${var.region}c"

  tags = {
    Name      = "${var.project_name}-${var.env}-subnet-protected-${var.region}c"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

resource "aws_subnet" "rds_private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name      = "${var.project_name}-${var.env}-subnet-rds-private-${var.region}a"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

resource "aws_subnet" "rds_private_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.21.0/24"
  availability_zone = "${var.region}c"

  tags = {
    Name      = "${var.project_name}-${var.env}-subnet-rds-private-${var.region}c"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

resource "aws_subnet" "elasticache_private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.30.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name      = "${var.project_name}-${var.env}-subnet-elasticache-private-${var.region}a"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

resource "aws_subnet" "elasticache_private_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.31.0/24"
  availability_zone = "${var.region}c"

  tags = {
    Name      = "${var.project_name}-${var.env}-subnet-elasticache-private-${var.region}c"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

# ルートテーブル
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name      = "${var.project_name}-${var.env}-public-route-table"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

resource "aws_route_table" "protected_a" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1a.id
  }

  tags = {
    Name      = "${var.project_name}-${var.env}-protected-a-route-table"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

resource "aws_route_table" "protected_c" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1c.id
  }

  tags = {
    Name      = "${var.project_name}-${var.env}-protected-c-route-table"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name      = "${var.project_name}-${var.env}-private-route-table"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name      = "${var.project_name}-${var.env}-internet-gateway"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

# EIP
resource "aws_eip" "nat_1a" {
  vpc = true

  tags = {
    Name      = "${var.project_name}-${var.env}-eip-natgw-1a"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}
resource "aws_eip" "nat_1c" {
  vpc = true

  tags = {
    Name      = "${var.project_name}-${var.env}-eip-natgw-1c"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "nat_1a" {
  subnet_id     = aws_subnet.public_a.id
  allocation_id = aws_eip.nat_1a.id

  tags = {
    Name      = "${var.project_name}-${var.env}-nat-1a"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

resource "aws_nat_gateway" "nat_1c" {
  subnet_id     = aws_subnet.public_c.id
  allocation_id = aws_eip.nat_1c.id

  tags = {
    Name      = "${var.project_name}-${var.env}-nat-1c"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

# ルートテーブルアソシエーション
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_c" {
  subnet_id      = aws_subnet.public_c.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "protected_a" {
  subnet_id      = aws_subnet.protected_a.id
  route_table_id = aws_route_table.protected_a.id
}

resource "aws_route_table_association" "protected_c" {
  subnet_id      = aws_subnet.protected_c.id
  route_table_id = aws_route_table.protected_c.id
}

resource "aws_route_table_association" "rds_private_a" {
  subnet_id      = aws_subnet.rds_private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "rds_private_c" {
  subnet_id      = aws_subnet.rds_private_c.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "elasticache_private_a" {
  subnet_id      = aws_subnet.elasticache_private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "elasticache_private_c" {
  subnet_id      = aws_subnet.elasticache_private_c.id
  route_table_id = aws_route_table.private.id
}

# Security Group
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-${var.env}-alb-sg"
  description = "${var.project_name}-${var.env}-alb-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.project_name}-${var.env}-alb-sg"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

resource "aws_security_group" "ecs_sg" {
  name        = "${var.project_name}-${var.env}-ecs-sg"
  description = "${var.project_name}-${var.env}-ecs-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "FROM ALB sg"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    description = "FROM Nginx"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.project_name}-${var.env}-ecs-sg"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-${var.env}-rds-sg"
  description = "${var.project_name}-${var.env}-rds-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "FROM ECS sg"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.project_name}-${var.env}-rds-sg"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

resource "aws_security_group" "elasticache_sg" {
  name        = "${var.project_name}-${var.env}-elasticache-sg"
  description = "${var.project_name}-${var.env}-elasticache-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "FROM ECS sg"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.project_name}-${var.env}-elasticache-sg"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

