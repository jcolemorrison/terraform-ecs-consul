# Terraform with Amazon ECS and Consul

This repository demonstrates setting up an Amazon ECS microservices architecture with HashiCorp Terraform and Consul.  It also goes along with two other repositories:

1. [CDK for Terraform with Amazon ECS and Consul](https://github.com/jcolemorrison/cdktf-ecs-consul)
  - deploys an additional ECS microservice via the [CDK for Terraform](https://www.terraform.io/cdktf)
2. [Sentinel Policies for Terraform with Amazon ECS and Consul](https://github.com/jcolemorrison/sentinel-ecs-consul)
  - creates [Sentinel Policies](https://www.hashicorp.com/sentinel) to guard both projects in [Terraform Cloud](https://cloud.hashicorp.com/products/terraform)

## The Architecture

![Terraform with Amazon ECS and Consul](images/terraform-ecs-consul.png)

All services use [Fake Service](https://github.com/nicholasjackson/fake-service) as for demonstration purposes.  You can swap them out with your own containerized services.  You will need to change around port configurations and security groups to afford your applications' needs.

## Getting Started

#### Prerequisites

1. Have an [AWS Account](https://aws.amazon.com/).

2. Install [HashiCorp Terraform](https://www.terraform.io/downloads).

3. Have the [AWS CLI Installed](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).

4. Create an [AWS IAM User](https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started_create-admin-group.html) with Admin or Power User Permissions.
  - this user will only be used locally

5. [Configure the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) with the IAM User from Step 4.
  - Terraform will read your credentials via the AWS CLI 
  - [Other Authentication Methods with AWS and Terraform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication)

#### Using this Code Locally

1. Clone this repo to an empty directory.

2. Run `terraform plan` to see what resources will be created.

3. Run `terraform apply` to create the infrastructure on AWS!

4. Open your Consul Server's Load Balancer (output as `consul_server_endpoint`).

5. Run `bash scripts/post-apply.sh` and follow the instructions OR open your terraform statefile and copy your Consul Bootstrap Token.  Use this to Login to the Consul UI.
  - It may take a few moments for all of the services to come on line.
  - you can also grab this from your Terraform State file, this script is only for convenience.

6. Click on **Services** in the side navigation and ensure all services are GREEN (denoted by a checkmark).

7. Navigate to your Client Application Load Balancer (output as `client_endpoint`) to confirm that everything is working.
  - It may take a few moments for the new intentions to be recognized.

8. Run `terraform destroy` when you're done to get rid of the infrastructure.

### Using this Code with Terraform Cloud

1. Fork this Repository.

2. [Signup for Terraform Cloud](https://hashi.co/ll-aws-hc-terraform-cloud).

3. [Setup your Terraform Cloud Account](https://learn.hashicorp.com/tutorials/terraform/cloud-sign-up?in=terraform/cloud-get-started).

4. [Connect Terraform Cloud to your AWS Account](https://learn.hashicorp.com/tutorials/terraform/cloud-create-variable-set?in=terraform/cloud-get-started).

5. [Create a Workspace in Terraform Cloud](https://learn.hashicorp.com/tutorials/terraform/cloud-workspace-create?in=terraform/cloud-get-started).  You'll need to reference this workspace name in the [CDKTF]() project if you deploy it.
  - optionally change the `workspaces` tags in `main.tf`

6. [Connect Your Repository to Terraform Cloud](https://learn.hashicorp.com/tutorials/terraform/cloud-vcs-change?in=terraform/cloud-get-started).

7. [Set All Required Variables specified in `variables.tf`](https://www.terraform.io/cloud-docs/workspaces/variables):
  - `ec2_key_pair_name`
  - `tfc_organization`
  - `tfc_workspace_tag`

8. [Trigger a Run to Plan and Apply Infrastructure](https://www.terraform.io/cloud-docs/run/manage)

### Guarding Your TFC Workspaces With [HashiCorp Sentinel](https://www.hashicorp.com/sentinel)

We can also insert an addition step between the `terraform plan` and `terraform apply` phases that checks our code, plan, statefile, and run data using [HashiCorp Sentinel](https://www.hashicorp.com/sentinel).

1. Fork the [Sentinel Policy Repo](https://github.com/jcolemorrison/sentinel-ecs-consul)

2. Head to **Settings** in your Terraform Cloud console

3. Click on **Policy Sets** in the side navigation bar

4. Click on **Connect a new policy set** in the **Policy Sets** screen

5. Follow the **Connect a Policy Set** step-by-step

6. Name the policy set whatever you'd like

7. Under the **Workspaces** area, select the specific workspaces you'd like this policy to guard.

8. Click **Connect policy set**

9. Optionally trigger a run in any of your workspaces to view the policy in action.

## Questions?  Suggestions?  Comments?

Reach out to [J. Cole Morrison](https://twitter.com/JColeMorrison).  Also, feel free to leave any issues you run into on this Github Repo!