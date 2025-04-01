locals {
  node_userdata = <<-USERDATA
    #!/bin/bash
    set -o xtrace
    /etc/eks/bootstrap.sh ${var.cluster-name} --apiserver-endpoint '${aws_eks_cluster.cluster_eks.endpoint}' --b64-cluster-ca '${aws_eks_cluster.cluster_eks.certificate_authority[0]["data"]}'
  USERDATA
}

resource "aws_launch_template" "cluster_eks" {
  name_prefix   = "terraform-eks-${var.env}"
  image_id      = var.image_id
  instance_type = "t3.medium"

  iam_instance_profile {
    name = aws_iam_instance_profile.node.name
  }

  network_interfaces {
    security_groups = [aws_security_group.node.id]
  }

  user_data = base64encode(local.node_userdata)

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "terraform-eks-${var.env}"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "cluster_eks" {
  desired_capacity     = 1
  max_size            = 2
  min_size            = 1
  vpc_zone_identifier = var.private_subnets

  launch_template {
    id      = aws_launch_template.cluster_eks.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "terraform-eks-${var.env}"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster-name}"
    value               = "owned"
    propagate_at_launch = true
  }

  depends_on = [aws_launch_template.cluster_eks]
}