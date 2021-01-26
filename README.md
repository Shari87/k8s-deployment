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
# Setup
The framework comprises of two folders k8s-yaml-config and terraform-k8s
1. **k8s-yaml-config**
    * This folder defines the following:
        * Creates and runs a sample hello backend microservice using a Deployment object
        * Uses a Service object to send traffic to the backend microservice's multiple replicas
        * Creates and runs a nginx frontend microservice, also using a Deployment object
        * Configures the frontend microservice to send traffic to the backend microservice
        * Use a Service object of type=LoadBalancer to expose the frontend microservice outside the cluster
    * **Creating the backend using a Deployment**
        * The backend is a simple hello greeter microservice
        * The deployment object can be created using the command
        ```bash
        kubectl apply -f backend-deployment.yaml
        ```
    * **Creating the hello service object**
        * The key to sending requests from a frontend to a backend is the backend Service
        * A Service creates a persistent IP address and DNS name entry so that the backend microservice can always be reached
        * A Service uses selectors to find the Pods that it routes traffic to
        * Create the backend Service:
        ```bash
        kubectl apply -f backend-service.yaml # the service object is defined in the deployment file, so this command needn't be run separately
        ```
    * **Creating the frontend**
        * The frontend sends requests to the backend worker Pods by using the DNS name given to the backend Service
        * The DNS name is **hello**, which is the value of the **name** field in the **examples/service/access/backend-service.yaml** configuration file
        * The Pods in the frontend Deployment run a nginx image that is configured to proxy requests to the hello backend Service
        * Create the frontend deployment and service:
        ```bash
        kubectl apply -f frontend-service.yaml  # # the service object is defined in the deployment file, so this command needn't be run separately
        kubectl apply -f frontend-deployment.yaml
        ```
        

