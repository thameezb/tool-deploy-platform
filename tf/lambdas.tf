//--------------------------------------------------------------------------------------------------------------------
// Creates lamba IAM role
resource "aws_iam_role" "allow_all_lambda" {
  name = "allow_all_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

// Attaches policy to role
resource "aws_iam_role_policy_attachment" "allow_all_lambda" {
  role       = aws_iam_role.allow_all_lambda.id
  policy_arn = data.aws_iam_policy.ag-allow_all.arn
}
