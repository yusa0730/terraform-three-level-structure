# ECS
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.env}-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name      = "${var.project_name}-${var.env}-ecs-cluster"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

resource "aws_ecs_task_definition" "main" {
  family                   = "${var.project_name}-${var.env}-ecs-task-definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      cpu       = 0
      memory    = 512
      name      = "nginx"
      image     = "${data.aws_ecr_repository.nginx.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      dependsOn = [
        {
          containerName = "php-fpm"
          condition     = "START"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-region"        = "${var.region}"
          "awslogs-group"         = "/ecs/${var.env}/web"
          "awslogs-stream-prefix" = "web"
        }
      }
    },
    {
      cpu       = 0
      memory    = 512
      name      = "php-fpm"
      image     = "${data.aws_ecr_repository.php-fpm.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 9000
          hostPort      = 9000
        }
      ]
      environment = [
        {
          name  = "DB_HOST"
          value = "${aws_rds_cluster.main.endpoint}"
        },
        {
          name  = "DB_USER"
          value = "myuser"
        },
        {
          name  = "DB_PASSWORD"
          value = "mypassword"
        },
        {
          name  = "DB_NAME"
          value = "mydatabase"
        },
        {
          name  = "DB_PORT"
          value = "3306"
        },
        {
          name  = "REDIS_HOST"
          value = "${aws_elasticache_replication_group.main.primary_endpoint_address}"
        },
        {
          name  = "REDIS_PORT"
          value = "6379"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-region"        = "${var.region}"
          "awslogs-group"         = "/ecs/${var.env}/app"
          "awslogs-stream-prefix" = "app"
        }
      }
    }
  ])

  tags = {
    Name      = "${var.project_name}-${var.env}-ecs-task-definition"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

resource "aws_ecs_service" "main" {
  name            = "${var.project_name}-${var.env}-ecs-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.id
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    assign_public_ip = false
    security_groups = [
      aws_security_group.ecs_sg.id
    ]

    subnets = [
      aws_subnet.protected_a.id,
      aws_subnet.protected_c.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = "nginx"
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [task_definition]
  }

  tags = {
    Name      = "${var.project_name}-${var.env}-ecs-service"
    Env       = var.env
    ManagedBy = "Terraform"
  }
}

