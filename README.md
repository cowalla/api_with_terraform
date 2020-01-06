# Deploying an API with Terraform and APIGateway

## What is this?
api_with_terraform demonstrates how to deploy lambda code as a service to API gateway. 

By following the steps below you will cause `example_handler` in lambda_handlers/example/lambda to respond to a request at `<aws_url>/example_path/example_stage/` 

## Requirements
### setting up AWS:

- AWS profile and account
- Credentials added to ~/.aws/credentials
- edit main.tf profile to point at name in ~/.aws/credentials

### setting up [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html):

For an easier install I like to move the Terraform executable to `/usr/local/bin/` which is on my PATH. You will know it is installed correctly when you can run, 
```
% terraform -v           127 ↵
Terraform v0.12.18
```

## Use
### package your lambda
Package your new lambda into a build.zip file,
- `python package_lambda.py example`

Set up Terraform in your lambda directory,
- `cd lambda_handlers/example`
- Run `terraform init`

See changes Terraform wants to run:
- `terraform plan`

Deploy your endpoint:
- `terraform apply`

Destroy your deployed resources:
- `terraform destroy`


 


