//--------------------------------------------------------------------------------------------------------------------
// Creates IAM role
resource "aws_iam_role" "ag-allow_all_ecs_task-role" {
  name = "ag-allow_all_ecs_task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

// Attaches policy to role
resource "aws_iam_role_policy_attachment" "ag-allow_all_ecs_task-role" {
  role       = aws_iam_role.ag-allow_all_ecs_task-role.id
  policy_arn = data.aws_iam_policy.ag-allow_all.arn
}
//--------------------------------------------------------------------------------------------------------------------
// Cluster 
resource "aws_ecs_cluster" "ret_de_test_ecs" {
  name = "ret_de_test_ecs"
  depends_on = [
    aws_iam_role_policy_attachment.ag-allow_all_ecs_task-role
  ]
}

//--------------------------------------------------------------------------------------------------------------------
// Capacity Providers 

resource "aws_ecs_capacity_provider" "ret_de_test_ecs" {
  name = "ret_de_test_ecs"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ret_de_ecs.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 1
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "ret_de_test_ecs" {
  cluster_name = aws_ecs_cluster.ret_de_test_ecs.name

  capacity_providers = ["FARGATE", aws_ecs_capacity_provider.ret_de_test_ecs.name]
}