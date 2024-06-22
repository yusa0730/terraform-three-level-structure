# RDS
# data "aws_ssm_parameter" "database_name" {
#   name = "${local.ssm_parameter_store_base}/database_name"
# }

# data "aws_ssm_parameter" "database_user" {
#   name = "${local.ssm_parameter_store_base}/database_user"
# }

# data "aws_ssm_parameter" "database_password" {
#   name = "${local.ssm_parameter_store_base}/database_password"
# }
resource "aws_db_subnet_group" "main" {
  name = "${var.project_name}-${var.env}-db-subnet-group"
  subnet_ids = [
    aws_subnet.rds_private_a.id,
    aws_subnet.rds_private_c.id
  ]

  tags = {
    Name      = "${var.project_name}-${var.env}-db-subnet-group"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

resource "aws_rds_cluster" "main" {
  cluster_identifier = "${var.project_name}-${var.env}-rds-cluster"

  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [
    aws_security_group.rds_sg.id
  ]
  availability_zones = [
    "ap-northeast-1a",
    "ap-northeast-1c"
  ]

  engine         = "aurora-mysql"
  engine_version = "5.7.mysql_aurora.2.12.0"
  port           = "3306"

  # database_name   = data.aws_ssm_parameter.database_name.value
  # master_username = data.aws_ssm_parameter.database_user.value
  # master_password = data.aws_ssm_parameter.database_password.value
  database_name   = "mydatabase"
  master_username = "myuser"
  master_password = "mypassword"

  # RDSインスタンス削除時のスナップショットの取得強制を無効化
  skip_final_snapshot = true
  apply_immediately   = true

  # 使用する Parameter Group を指定
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.main.name


  lifecycle {
    ignore_changes = [
      availability_zones,
      master_password
    ]
  }
  tags = {
    Name      = "${var.project_name}-${var.env}-rds-cluster"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

resource "aws_rds_cluster_instance" "writer" {
  count = 1

  identifier         = "${var.project_name}-${var.env}-rds-cluster-instance-writer"
  cluster_identifier = aws_rds_cluster.main.id

  engine         = aws_rds_cluster.main.engine
  engine_version = aws_rds_cluster.main.engine_version

  instance_class       = "db.t3.small"
  db_subnet_group_name = aws_rds_cluster.main.db_subnet_group_name

  availability_zone = "ap-northeast-1a"

  tags = {
    Name      = "${var.project_name}-${var.env}-writer-instance"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

resource "aws_rds_cluster_instance" "reader" {
  count = 1

  identifier         = "${var.project_name}-${var.env}-rds-cluster-instance-reader"
  cluster_identifier = aws_rds_cluster.main.id

  engine         = aws_rds_cluster.main.engine
  engine_version = aws_rds_cluster.main.engine_version

  instance_class       = "db.t3.small"
  db_subnet_group_name = aws_rds_cluster.main.db_subnet_group_name

  availability_zone = "ap-northeast-1c"

  tags = {
    Name      = "${var.project_name}-${var.env}-writer-instance"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

# resource "aws_rds_cluster_instance" "reader" {}
resource "aws_rds_cluster_parameter_group" "main" {
  name = "${var.project_name}-${var.env}-rds-cluster-pg"
  # family = "aurora-mysql8.0"
  family = "aurora-mysql5.7"

  parameter {
    name  = "time_zone"
    value = "Asia/Tokyo"
  }

  tags = {
    Name      = "${var.project_name}-${var.env}-rds-cluster-pg"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}
# resource "aws_db_parameter_group" "main" {}

