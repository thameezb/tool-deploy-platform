// ==========================================================================================================
// ECR

resource "aws_ecr_repository" "tool-container-benchmark" {
  name                 = "tool-container-benchmark"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

// output registry_url_benchmark {
//   value = aws_ecr_repository.tool-container-benchmark.repository_url
// }

resource "aws_ecr_repository" "tool-container-benchmark-" {
  name                 = "tool-container-benchmark-"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

// output registry_url_benchmark- {
//   value = aws_ecr_repository.tool-container-benchmark-.repository_url
// }


// ==========================================================================================================
// LAMBDA
//--------------------------------------------------------------------------------------------------------------------
// lambda
resource "aws_lambda_function" "tool-container-benchmark" {
  function_name = "ret_infra_tool_container_benchmark"
  timeout       = 900

  vpc_config {
    subnet_ids         = data.aws_subnets.compute_subnet.ids
    security_group_ids = [aws_security_group.allow_all.id]
  }

  role = aws_iam_role.allow_all_lambda.arn

  package_type = "Image"
  image_uri    = var.container_benchmark_image

  memory_size = 512

  environment {
    variables = {
      DB_HOST     = "",
      DB_NAME     = "ContainerBenchmarkLambda",
      DB_USERNAME = "",
      DB_PASSWORD = "",
      DB_PORT     = "1433",
      DEVELOPMENT = "true",
      LOG_LEVEL   = "debug",
      IS_LAMBDA   = "true",
      SCHEMA_NAME = "ContainerBenchmarkLambda",
    }
  }
}

// -----------------------------------------------------------------------------------------------------------
// ALB

resource "aws_lb" "ret_de_test_lambda" {
  name               = "ret-de-test-lambda"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_all.id]
  subnets            = data.aws_subnets.compute_subnet.ids
}

resource "aws_lb_target_group" "ret_infra_benchmark_lambda" {
  name        = "ret-infra-benchmark-lambda"
  target_type = "lambda"
}

resource "aws_lambda_permission" "with_lb" {
  statement_id  = "AllowExecutionFromlb"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tool-container-benchmark.arn
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_lb_target_group.ret_infra_benchmark_lambda.arn
}

resource "aws_lb_target_group_attachment" "ret_infra_benchmark_lambda" {
  target_group_arn = aws_lb_target_group.ret_infra_benchmark_lambda.arn
  target_id        = aws_lambda_function.tool-container-benchmark.arn
  depends_on       = [aws_lambda_permission.with_lb]
}

resource "aws_lb_listener" "ret_de_test_lambda" {
  load_balancer_arn = aws_lb.ret_de_test_lambda.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ret_infra_benchmark_lambda.arn
  }
}

output "container_benchmark_lambda_alb_url" {
  value = aws_lb.ret_de_test_lambda.dns_name
}

// ==========================================================================================================
// ECS EC2

// -----------------------------------------------------------------------------------------------------------
// ALB

resource "aws_lb" "ret_de_test_ecs_ec2" {
  name               = "ret-de-test-ecs-ec2"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_all.id]
  subnets            = data.aws_subnets.compute_subnet.ids
}

resource "aws_lb_target_group" "ret_infra_benchmark_ec2" {
  name        = "ret-infra-benchmark-ec2"
  target_type = "ip"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id

  health_check {
    enabled = true
    path    = "/container-benchmark/ping"
  }
}

resource "aws_lb_listener" "ret_de_test_ec2" {
  load_balancer_arn = aws_lb.ret_de_test_ecs_ec2.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ret_infra_benchmark_ec2.arn
  }
}

output "container_benchmark_ecs_ec2_alb_url" {
  value = aws_lb.ret_de_test_ecs_ec2.dns_name
}

// -----------------------------------------------------------------------------------------------------------
// EC2 Task
resource "aws_ecs_task_definition" "ret_infra_benchmark_ec2" {
  family                   = "ret_infra_benchmark"
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  requires_compatibilities = ["EC2"]
  task_role_arn            = aws_iam_role.ag-allow_all_ecs_task-role.arn
  container_definitions = templatefile("${path.module}/task-definitions/cm_taskDefinition.json", {
    image       = var.container_benchmark_image,
    app_name    = "tool-container-benchmark"
    launch_type = "ec2"
    db_name     = "ContainerBenchmarkECSEC2",
  })
}

resource "aws_ecs_service" "ret_infra_benchmark_ec2" {
  name                = "ret_infra_benchmark_ec2"
  cluster             = aws_ecs_cluster.ret_de_test_ecs.id
  task_definition     = aws_ecs_task_definition.ret_infra_benchmark_ec2.arn
  desired_count       = 1
  launch_type         = "EC2"
  scheduling_strategy = "REPLICA"

  enable_ecs_managed_tags = true

  network_configuration {
    subnets         = data.aws_subnets.compute_subnet.ids
    security_groups = [aws_security_group.allow_all.id]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.ret_infra_benchmark_ec2.arn
    container_name   = "tool-container-benchmark"
    container_port   = 3000
  }
}

// ==========================================================================================================
// ECS Fargate

// -----------------------------------------------------------------------------------------------------------
// ALB

resource "aws_lb" "ret_de_test_ecs_fargate" {
  name               = "ret-de-test-ecs-fargate"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_all.id]
  subnets            = data.aws_subnets.compute_subnet.ids
}

resource "aws_lb_target_group" "ret_infra_benchmark_fargate" {
  name        = "ret-infra-benchmark-fargate"
  target_type = "ip"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id

  health_check {
    enabled = true
    path    = "/container-benchmark/ping"
  }
}

resource "aws_lb_listener" "ret_de_test_fargate" {
  load_balancer_arn = aws_lb.ret_de_test_ecs_fargate.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ret_infra_benchmark_fargate.arn
  }
}

output "container_benchmark_ecs_fargate_alb_url" {
  value = aws_lb.ret_de_test_ecs_fargate.dns_name
}

// -----------------------------------------------------------------------------------------------------------
// ECS Fargate Task
resource "aws_ecs_task_definition" "ret_infra_benchmark_fargate" {
  family                   = "ret_infra_benchmark_fargate"
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.ag-allow_all_ecs_task-role.arn
  execution_role_arn       = aws_iam_role.ag-allow_all_ecs_task-role.arn
  container_definitions = templatefile("${path.module}/task-definitions/cm_taskDefinition.json", {
    image       = var.container_benchmark_image,
    app_name    = "tool-container-benchmark"
    launch_type = "fargate"
    launch_type = "ec2"
    db_name     = "ContainerBenchmarkECSFargate",

  })
}

resource "aws_ecs_service" "ret_infra_benchmark_fargate" {
  name            = "ret_infra_benchmark_fargate"
  cluster         = aws_ecs_cluster.ret_de_test_ecs.id
  task_definition = aws_ecs_task_definition.ret_infra_benchmark_fargate.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = data.aws_subnets.compute_subnet.ids
    security_groups = [aws_security_group.allow_all.id]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.ret_infra_benchmark_fargate.arn
    container_name   = "tool-container-benchmark"
    container_port   = 3000
  }
}
