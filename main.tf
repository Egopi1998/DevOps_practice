resource "aws_instance" "jenkins" {
  # count = length(var.instance_name)
  ami = data.aws_ami.ami_info.id
  instance_type = "t3.small"
  associate_public_ip_address = true
  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = self.public_ip
  }
  provisioner "file" {
    source      = "gopi.sh"
    destination = "/tmp/gopi.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "cd /tmp/",
      "sudo sh gopi.sh"
    ]
  }
  tags = {
    # Name = "Expense-${var.instance_name[count.index]}"
    Name = "Jenkins"
  }
}

resource "aws_route53_record" "jenkins" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "jenkins.${var.zone_id}"
  type    = "A"
  ttl     = 1
  records = [aws_instance.jenkins.public_ip]
}

# resource "aws_instance" "Expense" {
#   count = length(var.instance_name)
#   ami = data.aws_ami.ami_info.id
#   instance_type = "t2.micro"
#   associate_public_ip_address = var.instance_name[count.index] == "frontend" ? true : false
#   tags = {
#     Name = "Expense-${var.instance_name[count.index]}"
#     # Name = "Ansible"
#   }
# }

# resource "aws_route53_record" "ansible" {
#   zone_id = data.aws_route53_zone.selected.zone_id
#   name    = "ansible.${var.zone_id}"
#   type    = "A"
#   ttl     = 1
#   records = [aws_instance.ansible.public_ip]
# }
# resource "aws_route53_record" "db" {
#   zone_id = data.aws_route53_zone.selected.zone_id
#   name    = "${var.instance_name[0]}.${var.zone_id}"
#   type    = "A"
#   ttl     = 1
#   records = [aws_instance.Expense[0].private_ip]
# }
# resource "aws_route53_record" "backend" {
#   zone_id = data.aws_route53_zone.selected.zone_id
#   name    = "${var.instance_name[1]}.${var.zone_id}"
#   type    = "A"
#   ttl     = 1
#   records = [aws_instance.Expense[1].private_ip]
# }

# resource "aws_route53_record" "frontend" {
#   zone_id = data.aws_route53_zone.selected.zone_id
#   name    = "${var.instance_name[2]}.${var.zone_id}"
#   type    = "A"
#   ttl     = 1
#   records = [aws_instance.Expense[2].public_ip]
# }
# output "route53" {
#   value = aws_instance.shell[2].private_ip
# }
# # resource "null_resource" "backend" {
#   triggers = {
#     instance_id = aws_instance.backend.public_ip # it will execute when ever the ip changes 
#   }
#   connection {
#     type     = "ssh"
#     user     = "ec2-user"
#     private_key = file("./terraform.pem")
#     host     = aws_instance.backend.public_ip
#   }
#   provisioner "file" {
#     source = "./gopi.sh"
#     destination = "/tmp/gopi.sh"
#   }
#   provisioner "remote-exec" {
#     inline = [ 
#       "chmod 700 /tmp/gopi.sh",
#       "sh /tmp/gopi.sh"
#      ]
#   }
# }

# output "public_ip" {
#   value = aws_instance.backend.public_ip
# }

# resource "aws_ec2_instance_state" "backend" {
#   instance_id = aws_instance.backend.id
#   state       = "stopped"
#   depends_on = [ null_resource.backend ]
# }

# resource "aws_ami_from_instance" "backend" {
#   name               = "Backend"
#   source_instance_id = aws_instance.backend.id
#   depends_on = [ aws_ec2_instance_state.backend ]
# }
 

# resource "aws_launch_template" "backend" {
#   name = "backend"

#   image_id = aws_ami_from_instance.backend.id

#   instance_initiated_shutdown_behavior = "terminate"

#   instance_type = "t2.micro"
#   update_default_version = true

#   key_name = data.aws_key_pair.terraform.key_name

#   network_interfaces {
#     associate_public_ip_address = true
#   }

#   tag_specifications {
#     resource_type = "instance"

#     tags = {
#       Name = "backend"
#     }
#   }
# }

# resource "aws_lb_target_group" "test" {
#   name     = "backend"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = data.aws_vpc.default.id
#   health_check {
#     path                = "/"
#     port                = 8080
#     protocol            = "HTTP"
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#     matcher             = "200"
#   }
# }

# resource "aws_autoscaling_group" "backend" {
#   name                      = "backend"
#   max_size                  = 5
#   min_size                  = 1
#   health_check_grace_period = 300
#   health_check_type         = "ELB"
#   desired_capacity          = 1
#   vpc_zone_identifier = local.subnets
#   launch_template {
#     id      = aws_launch_template.backend.id
#     version = "$Latest"
#   }

#   instance_refresh {
#     strategy = "Rolling"
#     preferences {
#       min_healthy_percentage = 50
#     }
#     triggers = ["launch_template"]
#   }

#   tag {
#     key                 = "Name"
#     value               = "backend"
#     propagate_at_launch = true
#   }
# }

# resource "aws_lb" "test" {
#   name               = "backend"
#   internal           = false
#   load_balancer_type = "application"

#   subnets            = local.subnets

#   tags = {
#     Environment = "dev"
#   }
#   depends_on = [ aws_lb_target_group.test ]
# }

# resource "aws_autoscaling_policy" "bat" {
#   name                   = "backend"
#   scaling_adjustment     = 1
#   adjustment_type        = "ChangeInCapacity"

#   cooldown               = 300
#   autoscaling_group_name = aws_autoscaling_group.backend.name
# }