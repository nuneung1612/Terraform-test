// alb.tf
resource "aws_lb" "alb" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [for s in aws_subnet.public : s.id]
  depends_on         = [aws_security_group.alb_sg]

  tags = merge(var.tags, { Name = "web-alb" })
}

resource "aws_lb_target_group" "tg" {
  name     = "web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = merge(var.tags, { Name = "web-tg" })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }

  depends_on = [aws_lb_target_group.tg]
}

resource "aws_lb_target_group_attachment" "web_attach" {
  for_each         = aws_instance.web
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = each.value.id
  port             = 80
  depends_on       = [aws_lb_listener.http]
}
