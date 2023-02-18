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

### First Run Steps

1. Create the Codestar connection. (Go to CodeCommit and then go to Settings->Connections. Going to CodeStar directly takes you to a different place?)
1. Create a bastion box. New ec2 instance in the VPC, in the bastion SG, public IP. Save the key or use an existing.
1. Access the database and run `CREATE DATABASE `foxy-n8n`;`

### Subsequent Runs

```
terraform apply -input=false -var-file=env/stage.tfvars
```