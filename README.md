# K8s Deployment using Terraform
# Project Requirements
1. Create Terraform infra-as-code template for AWS/GCP, that can create:
    * VPC with private subnets in 3 different AZs, having NAT
    * Route53 zone
    * K8s cluster
    * Services running in the K8s cluster:
        * Statefulset: MySQL (DB)
        * Deployment: Apache + PHP (backend) serving simple 'Hello world' program, HPA: 3-12
        * Deployment: Nginx web-service (frontend) proxying requests to Tomcat
        * DNS: external-dns service that registers K8s services in Route53 automatically
2. Access to db ports has to be allowed from backend pods only

