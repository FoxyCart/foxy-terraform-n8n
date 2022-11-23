# Terraform for Foxy Automations (n8n)

* Terraform set up that uses proper module-style code, and variables for all dynamic or configurable data, to build the following:
* CloudFront + ALB
* Aurora MySQL
* Redis cluster mode
* CodePipeline, triggered from a github repo.
* CodeBuild outputting to ECR.
* CodeDeploy pushing to…
* ECS + Fargate

[n8n env variables](https://docs.n8n.io/hosting/environment-variables/#queues)

## Deploying

```
terraform apply -input=false -var-file=env/stage.tfvars
```