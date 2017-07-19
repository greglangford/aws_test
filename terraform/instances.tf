##################################################################################################

variable "instance_type" { default = "t2.nano" }
variable "key_name"      { default = ""        }

##################################################################################################

resource "aws_instance" "web_1" {
  ami                         = "${data.aws_ami.ubuntu_ami.id}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  subnet_id                   = "${var.subnet-eu-west-1a}"
  iam_instance_profile        = "${aws_iam_instance_profile.elb_profile.name}"
  vpc_security_group_ids      = [ "${aws_security_group.perimeter.id}" ]
  associate_public_ip_address = true

  tags {
    Name  = "web-1",
    Class = "web-server"
  }
}

##################################################################################################

resource "aws_instance" "web_2" {
  ami                         = "${data.aws_ami.ubuntu_ami.id}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  subnet_id                   = "${var.subnet-eu-west-1b}"
  iam_instance_profile        = "${aws_iam_instance_profile.elb_profile.name}"
  vpc_security_group_ids      = [ "${aws_security_group.perimeter.id}" ]
  associate_public_ip_address = true

  tags {
    Name = "web-2",
    Class = "web-server"
  }
}

##################################################################################################

data "aws_ami" "ubuntu_ami" {
  most_recent = false

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-20170619.1"]
  }
}

##################################################################################################

output "ami_id"            { value = "${data.aws_ami.ubuntu_ami.id}"   }
output "instance-id-web-1" { value = "${aws_instance.web_1.id}"        }
output "instance-id-web-2" { value = "${aws_instance.web_2.id}"        }
output "public-ip-web-1"   { value = "${aws_instance.web_1.public_ip}" }
output "public-ip-web-2"   { value = "${aws_instance.web_2.public_ip}" }

##################################################################################################
