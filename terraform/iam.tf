##################################################################################################

resource "aws_iam_role" "elb_role" {
  name = "elb-role"
  assume_role_policy = <<EOF
{
  "Version"  : "2012-10-17",
  "Statement": [
    {
      "Sid"      : "1",
      "Effect"   : "Allow",
      "Action"   : "sts:AssumeRole",
      "Principal": { "Service": "ec2.amazonaws.com" }
    }
  ]
}
EOF
}

##################################################################################################

resource "aws_iam_instance_profile" "elb_profile" {
  name = "elb-profile"
  role = "${aws_iam_role.elb_role.id}"
}

##################################################################################################

resource "aws_iam_role_policy" "web_balancer_policy" {
  role   = "${aws_iam_role.elb_role.id}"
  name   = "web-balancer"
  policy = <<EOF
{
  "Version"  : "2012-10-17",
  "Statement": [
    {
      "Sid"     :   "1",
      "Effect"  :   "Allow",
      "Action"  : [ "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
                    "elasticloadbalancing:DeregisterInstancesFromLoadBalancer" ],
      "Resource":   "arn:aws:elasticloadbalancing:${var.region}:${var.account_id}:loadbalancer/${var.elb-name}"
    }
  ]
}
EOF
}

##################################################################################################
