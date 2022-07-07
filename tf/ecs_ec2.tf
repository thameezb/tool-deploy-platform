// -----------------------------------------------------------------------------------------------------------

data "aws_ami" "ag_ret_ami_ecs" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ag-ret-ecs-*"]
  }
  owners = [ data.aws_caller_identity.current.account_id ]  
}

resource "aws_launch_template" "ret_de_test_ecs" {
  name = "ret_de_test_ecs-${formatdate("mm-DD-MM",timestamp())}"
  image_id    = data.aws_ami.ag_ret_ami_ecs.id

  key_name = "test-de"

  credit_specification {
    cpu_credits = "standard"
  }

  iam_instance_profile {
      arn = aws_iam_instance_profile.ag-allow_all_ec2.arn
  } 
  
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "m5.2xlarge"
  
  vpc_security_group_ids = [aws_security_group.allow_all.id]

  user_data = base64encode(file("${path.module}/scripts/bootstrap.sh"))
}

// --------------------------------------------------------------------------------------\
// Autoscaling group

resource "aws_autoscaling_group" "ret_de_ecs"{
  name = "ret_de_ecs"
  vpc_zone_identifier = data.aws_subnets.compute_subnet.ids

  desired_capacity   = 1
  max_size           = 1
  min_size           = 0

  max_instance_lifetime = 86400
  health_check_type     = "EC2"
  protect_from_scale_in = true 

  launch_template {
    id      = aws_launch_template.ret_de_test_ecs.id
    version = "$Latest"
  }
  
  dynamic "tag" {
    for_each = merge(data.aws_default_tags.current.tags,{"AmazonECSManaged"=true})
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}
