# =====================================================
# 3-TIER ARCHITECTURE FOR TERRAFORM
# Web Tier (ALB + Web Servers) | App Tier | DB Tier
# =====================================================

data "aws_availability_zones" "available" {
  state = "available"
}

# =====================================================
# NETWORKING LAYER - VPC & SUBNETS
# =====================================================

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.environment}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-igw"
  }
}

# WEB TIER SUBNETS (Public)
resource "aws_subnet" "web_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.web_subnet_1_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}-web-subnet-1"
    Tier = "Web"
  }
}

resource "aws_subnet" "web_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.web_subnet_2_cidr
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}-web-subnet-2"
    Tier = "Web"
  }
}

# APPLICATION TIER SUBNETS (Private)
resource "aws_subnet" "app_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.app_subnet_1_cidr
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "${var.environment}-app-subnet-1"
    Tier = "Application"
  }
}

resource "aws_subnet" "app_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.app_subnet_2_cidr
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "${var.environment}-app-subnet-2"
    Tier = "Application"
  }
}

# DATABASE TIER SUBNETS (Private)
resource "aws_subnet" "db_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.db_subnet_1_cidr
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "${var.environment}-db-subnet-1"
    Tier = "Database"
  }
}

resource "aws_subnet" "db_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.db_subnet_2_cidr
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "${var.environment}-db-subnet-2"
    Tier = "Database"
  }
}

# =====================================================
# ROUTE TABLES & ROUTES
# =====================================================

# Public Route Table for Web Tier
resource "aws_route_table" "web_public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.environment}-web-rt"
  }
}

resource "aws_route_table_association" "web_1" {
  subnet_id      = aws_subnet.web_1.id
  route_table_id = aws_route_table.web_public.id
}

resource "aws_route_table_association" "web_2" {
  subnet_id      = aws_subnet.web_2.id
  route_table_id = aws_route_table.web_public.id
}

# NAT Gateway for App Tier
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.environment}-eip-nat"
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.web_1.id

  tags = {
    Name = "${var.environment}-nat-gw"
  }

  depends_on = [aws_internet_gateway.main]
}

# Private Route Table for App Tier
resource "aws_route_table" "app_private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.environment}-app-rt"
  }
}

resource "aws_route_table_association" "app_1" {
  subnet_id      = aws_subnet.app_1.id
  route_table_id = aws_route_table.app_private.id
}

resource "aws_route_table_association" "app_2" {
  subnet_id      = aws_subnet.app_2.id
  route_table_id = aws_route_table.app_private.id
}

# Private Route Table for DB Tier
resource "aws_route_table" "db_private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-db-rt"
  }
}

resource "aws_route_table_association" "db_1" {
  subnet_id      = aws_subnet.db_1.id
  route_table_id = aws_route_table.db_private.id
}

resource "aws_route_table_association" "db_2" {
  subnet_id      = aws_subnet.db_2.id
  route_table_id = aws_route_table.db_private.id
}

# =====================================================
# SECURITY GROUPS
# =====================================================

# ALB Security Group
resource "aws_security_group" "alb_sg" {
  name_prefix = "alb-sg-"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
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
    Name = "${var.environment}-alb-sg"
  }
}

# Web Server Security Group
resource "aws_security_group" "web_sg" {
  name_prefix = "web-sg-"
  description = "Security group for web servers"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    description     = "HTTPS from ALB"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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
    Name = "${var.environment}-web-sg"
  }
}

# Application Server Security Group
resource "aws_security_group" "app_sg" {
  name_prefix = "app-sg-"
  description = "Security group for application servers"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "App traffic from web servers"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  ingress {
    description = "SSH from web tier"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.web_subnet_1_cidr, var.web_subnet_2_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-app-sg"
  }
}

# Database Security Group
resource "aws_security_group" "db_sg" {
  name_prefix = "db-sg-"
  description = "Security group for database"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MySQL from app servers"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-db-sg"
  }
}

# =====================================================
# APPLICATION LOAD BALANCER
# =====================================================

resource "aws_lb" "main" {
  name_prefix        = "web"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.web_1.id, aws_subnet.web_2.id]

  tags = {
    Name = "${var.environment}-alb"
  }
}

resource "aws_lb_target_group" "web_tg" {
  name_prefix = "web"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/"
    matcher             = "200"
  }

  tags = {
    Name = "${var.environment}-web-tg"
  }
}

resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

# =====================================================
# WEB TIER - EC2 INSTANCES
# =====================================================

resource "aws_instance" "web_1" {
  ami                     = var.ami_id
  instance_type           = var.web_instance_type
  subnet_id               = aws_subnet.web_1.id
  vpc_security_group_ids  = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
  user_data               = base64encode(file("${path.module}/userdata.sh"))

  tags = {
    Name = "${var.environment}-web-server-1"
    Tier = "Web"
  }
}

resource "aws_instance" "web_2" {
  ami                     = var.ami_id
  instance_type           = var.web_instance_type
  subnet_id               = aws_subnet.web_2.id
  vpc_security_group_ids  = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
  user_data               = base64encode(file("${path.module}/userdata1.sh"))

  tags = {
    Name = "${var.environment}-web-server-2"
    Tier = "Web"
  }
}

resource "aws_lb_target_group_attachment" "web_1" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "web_2" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web_2.id
  port             = 80
}

# =====================================================
# APPLICATION TIER - EC2 INSTANCES
# =====================================================

resource "aws_instance" "app_1" {
  ami                    = var.ami_id
  instance_type          = var.app_instance_type
  subnet_id              = aws_subnet.app_1.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  user_data              = base64encode(file("${path.module}/app_userdata.sh"))

  tags = {
    Name = "${var.environment}-app-server-1"
    Tier = "Application"
  }
}

resource "aws_instance" "app_2" {
  ami                    = var.ami_id
  instance_type          = var.app_instance_type
  subnet_id              = aws_subnet.app_2.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  user_data              = base64encode(file("${path.module}/app_userdata.sh"))

  tags = {
    Name = "${var.environment}-app-server-2"
    Tier = "Application"
  }
}

# =====================================================
# DATABASE TIER - RDS
# =====================================================

resource "aws_db_subnet_group" "main" {
  name_prefix = "db-"
  subnet_ids  = [aws_subnet.db_1.id, aws_subnet.db_2.id]
}

resource "aws_db_instance" "main" {
  identifier     = "${var.environment}-db-instance"
  engine         = var.db_engine
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  allocated_storage    = 20
  storage_type         = "gp2"
  storage_encrypted    = false

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  multi_az               = true
  publicly_accessible    = false
  skip_final_snapshot    = true
  backup_retention_period = 0

  tags = {
    Name = "${var.environment}-rds-db"
    Tier = "Database"
  }
}

# =====================================================
# S3 STORAGE
# =====================================================

resource "aws_s3_bucket" "main" {
  bucket_prefix = "${var.environment}-app-"

  tags = {
    Name = "${var.environment}-s3-bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

