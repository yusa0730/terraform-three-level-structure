resource "aws_elasticache_replication_group" "main" {
  replication_group_id = "${var.project_name}-${var.env}-redis"
  description          = "Redis Replication Group for multi-region"
  engine               = "redis"
  port                 = 6379
  node_type            = "cache.t4g.small"
  security_group_ids = [
    aws_security_group.elasticache_sg.id
  ]
  automatic_failover_enabled = true
  multi_az_enabled           = true
  parameter_group_name       = aws_elasticache_parameter_group.main.name
  subnet_group_name          = aws_elasticache_subnet_group.main.name

  num_cache_clusters = 2

  # maintenance_window       = "fri:13:30-fri:14:30"
  # snapshot_retention_limit = "1"
  # snapshot_window          = "16:00-17:00"

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.redis_engine_logs.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "engine-log"
  }

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.redis_slow_logs.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "slow-log"
  }

  tags = {
    Name      = "${var.project_name}-${var.env}-elasticache-replication-group"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

resource "aws_elasticache_subnet_group" "main" {
  name        = "${var.project_name}-${var.env}-elasticache-subnet-group"
  description = "ElastiCache subnet group for malti AZ"

  subnet_ids = [
    aws_subnet.elasticache_private_a.id,
    aws_subnet.elasticache_private_c.id
  ]

  tags = {
    Name      = "${var.project_name}-${var.env}-elasticache-subnet-group"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

resource "aws_elasticache_parameter_group" "main" {
  name   = "${var.project_name}-${var.env}-elasticache-parameter-group"
  family = "redis7"

  parameter {
    name  = "cluster-enabled"
    value = "no"
  }

  tags = {
    Name      = "${var.project_name}-${var.env}-elasticache-parameter-group"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

