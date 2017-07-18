##################################################################################################

variable "elb-name" { default = "elb-web-balancer" }

##################################################################################################

resource "aws_elb" "web_balancer" {
  name            = "${var.elb-name}"
  subnets         = [ "${var.subnet-eu-west-1a}", "${var.subnet-eu-west-1b}" ]
  security_groups = [ "${aws_security_group.perimeter.id}" ]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 15
  }

  tags {
    Name = "elb-web-balancer"
  }
}

##################################################################################################

output "elb_hostname" { value = "${aws_elb.web_balancer.dns_name}" }

##################################################################################################
