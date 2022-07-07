resource "aws_db_subnet_group" "ret-db-subnets" {
  name       = "ret_de_subnets"
  subnet_ids = data.aws_subnets.storage_subnet.ids
}

resource "aws_db_instance" "rds-container-benchmark" {
  identifier        = "ret-de-test"
  allocated_storage = 20
  apply_immediately = true
  engine            = "sqlserver-web"
  engine_version    = "15.00"

  username = ""
  password = ""

  instance_class         = "db.m5.large"
  db_subnet_group_name   = aws_db_subnet_group.ret-db-subnets.name
  vpc_security_group_ids = [aws_security_group.allow_all.id]

  storage_encrypted   = true
  skip_final_snapshot = true
}
