# ALB
resource "aws_lb" "main" {
  name               = "asg-rollout-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids
}

resource "aws_security_group" "alb" {
  name        = "asg-rollout-alb-sg"
  description = "Allow HTTP traffic to ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_lb_target_group" "blue" {
  name     = "asg-rollout-blue-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path = "/health"
  }
}

resource "aws_lb_target_group" "green" {
  name     = "asg-rollout-green-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path = "/health"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }
}
