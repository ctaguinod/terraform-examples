# aws-ec2-instance

Terraform example to provision AWS EC2 instances with additional EBS Volume for Data.

### How to Use:
1. rename `terraform-tfvars-sample` to `terraform.tfvars` and fill in the variables.
2. `terraform init`
3. `terraform plan`
4. `terraform apply`
5. `terraform destroy` - will destroy all resources, might need to manually detach or delete data volume.
