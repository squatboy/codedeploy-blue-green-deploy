# ASG
resource "aws_security_group" "ec2" {
  name        = "asg-rollout-ec2-sg"
  description = "Allow traffic from ALB to EC2 and SSH"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  ingress {
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
}

resource "aws_launch_template" "main" {
  name_prefix            = "asg-rollout-lt-"
  image_id               = data.aws_ami.ubuntu_22_04.id
  instance_type          = "t2.micro"
  key_name               = var.ssh_key_name
  vpc_security_group_ids = [aws_security_group.ec2.id]
  iam_instance_profile {
    name = var.ec2_instance_profile_name
  }
  user_data = base64encode(<<-EOF
              #!/bin/bash
              set -e -x
              
              # Update and install dependencies
              apt-get update -y
              apt-get install -y ruby-full wget
              
              # Install Docker
              apt-get install -y docker.io
              systemctl start docker
              systemctl enable docker
              usermod -a -G docker ubuntu
              
              # Install AWS CodeDeploy agent
              cd /home/ubuntu
              wget https://aws-codedeploy-ap-northeast-2.s3.ap-northeast-2.amazonaws.com/latest/install
              chmod +x ./install
              ./install auto
              
              # Start and enable the CodeDeploy agent service
              systemctl start codedeploy-agent
              systemctl enable codedeploy-agent
              EOF
  )
}

data "aws_ami" "ubuntu_22_04" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_autoscaling_group" "blue" {
  name                = "asg-rollout-blue"
  min_size            = 1
  max_size            = 2
  desired_capacity    = 1
  vpc_zone_identifier = var.public_subnet_ids
  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }
  target_group_arns = [var.blue_target_group_arn]
  tag {
    key                 = "Name"
    value               = "asg-rollout-blue"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group_tag" "blue_name" {
  autoscaling_group_name = aws_autoscaling_group.blue.name

  tag {
    key                 = "Name"
    value               = "asg-rollout-blue"
    propagate_at_launch = false
  }
}
