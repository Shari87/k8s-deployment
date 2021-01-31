
resource "aws_security_group" "ecs_alb_security_group" {
  name        = "${var.eks_cluster_name}-ALB-SG"
  description = "Security Group for ALB to traffic for EKS cluster"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 443
    protocol    = "TCP"
    to_port     = 443
    cidr_blocks = [var.internet_cidr_blocks]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = [var.internet_cidr_blocks]
  }
}