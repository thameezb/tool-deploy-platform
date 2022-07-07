// --------------------------------------------------------------------------------------\
// EC2 Instances
resource "aws_iam_role" "ag-allow_all_ec2-role" {
  name = "ag-allow_all_ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

// Attaches policy to role
resource "aws_iam_role_policy_attachment" "ag-allow_all_ec2" {
  role       = aws_iam_role.ag-allow_all_ec2-role.id
  policy_arn = data.aws_iam_policy.ag-allow_all.arn
}

resource "aws_iam_instance_profile" "ag-allow_all_ec2" {
  name = "ag-allow_all_ec2"
  role = aws_iam_role.ag-allow_all_ec2-role.name
}
