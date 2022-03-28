# Terraform for Foxy Automations (n8n)

* Terraform set up that uses proper module-style code, and variables for all dynamic or configurable data, to build the following:
* CloudFront + ALB
* Aurora MySQL
* Redis cluster mode
* CodePipeline, triggered from a github repo.
* CodeBuild outputting to ECR.
* CodeDeploy pushing to…
* ECS + Fargate
