# DevOps Practical Test – End-to-End CI/CD Deployment on AWS ECS Fargate

## Project Overview

This project demonstrates a complete production-style DevOps implementation using AWS cloud-native services, Infrastructure as Code, containerization, CI/CD automation, and security best practices.

The Node.js Shopping Cart application was deployed on AWS ECS Fargate using Docker containers, automated through Jenkins CI/CD pipelines, and provisioned entirely using Terraform.

---

# Architecture Overview

```text
                    +----------------------+
                    |      GitHub Repo     |
                    +----------+-----------+
                               |
                               v
                    +----------------------+
                    |     Jenkins Master   |
                    +----------+-----------+
                               |
                               v
                    +----------------------+
                    |     Jenkins Agent    |
                    |  (Docker + AWS CLI)  |
                    +----------+-----------+
                               |
          +--------------------+--------------------+
          |                                         |
          v                                         v
+----------------------+               +----------------------+
|   Amazon ECR         |               |   Terraform IaC      |
| Docker Image Repo    |               | AWS Infrastructure   |
+----------+-----------+               +----------------------+
           |
           v
+----------------------+
|    ECS Fargate       |
|  Container Service   |
+----------+-----------+
           |
           v
+----------------------+
| Application Load     |
| Balancer (ALB)       |
+----------+-----------+
           |
           v
+----------------------+
| Node.js Application  |
+----------------------+
```

---

# Task 1 — Infrastructure as Code (Foundation Layer)

## Goal

Provision complete AWS infrastructure using Terraform.

---

## Implemented Resources

### Networking
- VPC
- 2 Public Subnets (Multi-AZ)
- 2 Private Subnets (Multi-AZ)
- Internet Gateway
- NAT Gateway
- Route Tables

### Security
- Security Groups
- Least-Privilege IAM Roles

### Compute
- ECS Cluster
- Jenkins Master EC2
- Jenkins Agent EC2

### Storage
- S3 bucket support for Terraform state (optional setup)

---

## Terraform Structure

```text
devops-assignment/
│
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
│
├── modules/
│   ├── vpc/
│   ├── ecs/
│   ├── alb/
│   ├── ecr/
│   ├── security/
│   └── jenkins/
│
└── Shopping-Cart-Application/
```

---

## Terraform Commands

### Initialize Terraform

```bash
terraform init
```

### Validate Configuration

```bash
terraform validate
```

### Deploy Infrastructure

```bash
terraform apply
```

### Destroy Infrastructure

```bash
terraform destroy
```

---

## Screenshots to Attach

- Terraform Project Structure
- Terraform Apply Output
- VPC Resources
- ECS Cluster
- ALB
- Jenkins EC2 Instances

---

# Task 2 — AWS Application Deployment (Configuration Layer)

## Goal

Deploy NodeJS application using AWS best practices.

---

## Application Used

GitHub Repository:

https://github.com/mehediislamripon/Shopping-Cart-Application

---

## Deployment Architecture

- Application deployed on ECS Fargate
- Application exposed using Application Load Balancer
- CloudWatch logging enabled
- IAM Role-based access implemented
- No AWS access keys used

---

## ECS Components

- ECS Cluster
- ECS Service
- ECS Task Definition
- Target Group
- Application Load Balancer
- CloudWatch Logs

---

## CloudWatch Logging

Container logs were configured using:

```json
"logConfiguration": {
  "logDriver": "awslogs"
}
```

---

## Application URL

```text
http://devops-alb-1126958801.ap-south-1.elb.amazonaws.com
```

---

## Screenshots to Attach

- ECS Service Running
- ECS Tasks
- ALB Health Check
- CloudWatch Logs
- Working Application URL

---

# Task 3 — Containerization (Packaging Layer)

## Goal

Containerize the NodeJS application using Docker best practices.

---

# Final Dockerfile

```dockerfile
# ---------- BUILD STAGE ----------
FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

RUN npm cache clean --force


# ---------- PRODUCTION STAGE ----------
FROM node:18-alpine

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

COPY --from=builder /app /app

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

USER appuser

EXPOSE 3000

CMD ["node", "src/index.js"]
```

---

## Docker Best Practices Implemented

- Multi-stage Docker build
- Lightweight Alpine image
- Non-root container user
- Environment variable support
- Optimized runtime image
- Reduced image size

---

## Docker Commands Used

### Build Docker Image

```bash
docker build -t devops-app:v1 .
```

### Run Docker Container

```bash
docker run -p 3000:3000 devops-app:v1
```

### Push Image to ECR

```bash
docker push 438987839500.dkr.ecr.ap-south-1.amazonaws.com/devops-app:v1
```

---

## ECR Repository

```text
438987839500.dkr.ecr.ap-south-1.amazonaws.com/devops-app
```

---

## Screenshots to Attach

- Dockerfile
- Docker Build Output
- Docker Running Container
- ECR Repository
- Docker Push Output

---

# Task 4 — CI/CD with Jenkins (Automation Layer)

## Goal

Automate the deployment pipeline using Jenkins.

---

# Jenkins Architecture

## Jenkins Master
Responsibilities:
- Pipeline orchestration
- Job management
- Build scheduling

## Jenkins Agent
Responsibilities:
- Docker build
- ECR authentication
- Image push
- ECS deployment

---

# Jenkins Pipeline Stages

1. Clone Repository
2. Build Docker Image
3. Tag Docker Image
4. Login to ECR
5. Push Docker Image
6. Deploy to ECS

---

# Final Jenkinsfile

```groovy
pipeline {
    agent { label 'docker-agent' }

    environment {
        AWS_REGION = 'ap-south-1'
        ECR_REPO = '438987839500.dkr.ecr.ap-south-1.amazonaws.com/devops-app'
        IMAGE_TAG = "v${BUILD_NUMBER}"
        ECS_CLUSTER = 'devops-ecs-cluster'
        ECS_SERVICE = 'devops-app-service'
    }

    stages {

        stage('Clone Repository') {
            steps {
                git branch: 'master', url: 'https://github.com/Ekta6718/devops-assignment.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t devops-app:${IMAGE_TAG} .'
            }
        }

        stage('Tag Docker Image') {
            steps {
                sh 'docker tag devops-app:${IMAGE_TAG} ${ECR_REPO}:${IMAGE_TAG}'
            }
        }

        stage('Login to ECR') {
            steps {
                sh '''
                aws ecr get-login-password --region ${AWS_REGION} | \
                docker login --username AWS --password-stdin 438987839500.dkr.ecr.ap-south-1.amazonaws.com
                '''
            }
        }

        stage('Push Image to ECR') {
            steps {
                sh 'docker push ${ECR_REPO}:${IMAGE_TAG}'
            }
        }

        stage('Deploy to ECS') {
            steps {
                sh '''
                aws ecs update-service \
                --cluster ${ECS_CLUSTER} \
                --service ${ECS_SERVICE} \
                --force-new-deployment \
                --region ${AWS_REGION}
                '''
            }
        }
    }
}
```

---

# Security Best Practices

## IAM Roles
- Role-based authentication
- No hardcoded AWS keys

## Least Privilege Policy
- Limited ECR access
- Limited ECS deployment permissions

## Container Security
- Non-root Docker user
- Private subnet ECS deployment

---

# CI/CD Workflow

```text
Developer Pushes Code
        |
        v
Jenkins Pipeline Starts
        |
        v
Clone Repository
        |
        v
Docker Build
        |
        v
Push Image to ECR
        |
        v
ECS Rolling Deployment
        |
        v
Application Available via ALB
```

---

# Rollback Strategy

Rollback can be performed by:
- Deploying previous Docker image tag from ECR
- Reverting ECS task definition revision
- Restarting ECS service with stable image

---

# Challenges Faced

## Issues Resolved

- ECS task failures
- ARM64 vs AMD64 image issues
- Jenkins agent connectivity issues
- Docker daemon permission issues
- ECR manifest access errors
- IAM least privilege tuning

---

# Final Outcome

Successfully implemented:

- Terraform Infrastructure as Code
- Dockerized Node.js Application
- Amazon ECR Integration
- ECS Fargate Deployment
- Jenkins Master-Agent Architecture
- CI/CD Automation
- IAM Least Privilege Security
- CloudWatch Logging
- Rolling Deployments

---

# Future Improvements

- GitHub Webhook Automation
- Blue-Green Deployment
- Dynamic ECS Task Definition Updates
- HTTPS with ACM
- Auto Scaling
- Monitoring with Prometheus/Grafana

---

# Author

Ekta Sharma

DevOps Practical Test Submission
