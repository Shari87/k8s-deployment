resource "aws_acm_certificate" "eks_domain_certificate" {
  domain_name       = "*.${var.eks_domain_name}"
  validation_method = "DNS"

  tags = {
    Name = "${var.eks_cluster_name}-Certificate"
  }
}

data "aws_route53_zone" "eks_domain" {
  name         = var.eks_domain_name
  private_zone = false
}

resource "aws_route53_record" "eks_cert_validation_record" {
  for_each = {
    for dvo in aws_acm_certificate.eks_domain_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
    }


  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.eks_domain.zone_id
}

resource "aws_acm_certificate_validation" "eks_domain_certificate_validation" {
  certificate_arn         = aws_acm_certificate.eks_domain_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.eks_cert_validation_record : record.fqdn]
}

resource "aws_route53_record" "eks_load_balancer_record" {
  name    = "*.${var.eks_domain_name}"
  type    = "A"
  zone_id = data.aws_route53_zone.eks_domain.zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_alb.eks_cluster_alb.dns_name
    zone_id                = aws_alb.eks_cluster_alb.zone_id
  }
}

resource "aws_iam_role" "ecs_cluster_role" {
  name               = "${var.eks_cluster_name}-IAM-Role"
  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
  {
    "Effect": "Allow",
    "Principal": {
      "Service": ["eks.amazonaws.com", "ec2.amazonaws.com", "application-autoscaling.amazonaws.com"]
    },
    "Action": "sts:AssumeRole"
  }
  ]
}
EOF

}

resource "aws_iam_role_policy" "eks_cluster_policy" {
  name   = "${var.eks_cluster_name}-IAM-Policy"
  role   = aws_iam_role.eks_cluster_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "eks:*",
        "ec2:*",
        "elasticloadbalancing:*",
        "ecr:*",
        "dynamodb:*",
        "cloudwatch:*",
        "s3:*",
        "rds:*",
        "sqs:*",
        "sns:*",
        "logs:*",
        "ssm:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF

}