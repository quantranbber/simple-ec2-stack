# SIMPLE EC2 STACK
## This project contains the following technologies:
- Cloud provider: AWS
- IaC tool: Terraform
- Runtime: Node.js
- Script language: bash
- Containerize: Docker

## Deploy instruction:
### Required installations:
- AWS CLI
- Terraform version 1.9.8
- Docker engine
- Node.js runtime

### Instructions:
#### Init Terraform project:
- Run commandline:
```bash
sh scripts/init.sh
```

#### Environment variables file:
- Ensure declared variables in `variable-dev.tfvars`

#### Init Terraform project:
- Run commandline:
```bash
sh scripts/init.sh
```

#### Deploy Terraform project:
- Run commandline:
```bash
sh scripts/deploy.sh
```
