# AWS Config Remediation PoC

This is a PoC for AWS Config remediation on one targeted account and region using predefined remediation runbook owned by AWS.

Ideally we would enable Config service as a part of AWS Orgnisation services to ensure config is enabled on all member accounts and regions.

In this poc we demonstrate deployment of managed AWS Config Rule and its predefined remediation action.

### Config Rule Deployed

- S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED
- S3_BUCKET_VERSIONING_ENABLED

### Remediation

- AWS-EnableS3BucketEncryption
- AWS-ConfigureS3BucketVersioning

## To Apply this

1. Ensure AWS profile has necessary permissions

from cli run

`export AWS_PROFILE=profilename` 

2. Run Terraform

`terraform init`
`terraform apply`