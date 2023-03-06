### Enable AWS Config Recorder
resource "aws_config_configuration_recorder" "foo" {
  name     = "CloudSecRecorder"
  role_arn = aws_iam_role.this.arn
}


### Check encyption is enabled
resource "aws_config_config_rule" "this" {
  name = "s3EncStatus"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  }
  depends_on = [aws_config_configuration_recorder.foo]
}
### Ensure encyption is enabled
resource "aws_config_remediation_configuration" "this" {
  config_rule_name = aws_config_config_rule.this.name
  resource_type    = "AWS::S3::Bucket"
  target_type      = "SSM_DOCUMENT"
  target_id        = "AWS-EnableS3BucketEncryption"
  target_version   = "1"

  parameter {
    name         = "AutomationAssumeRole"
    static_value = aws_iam_role.SecAutomationRole.arn
  }
  parameter {
    name           = "BucketName"
    resource_value = "RESOURCE_ID"
  }

  automatic                  = true
  maximum_automatic_attempts = 10
  retry_attempt_seconds      = 200

  execution_controls {
    ssm_controls {
      concurrent_execution_rate_percentage = 25
      error_percentage                     = 20
    }
  }
}


## Check s3 versioning
resource "aws_config_config_rule" "S3VersionEnabled" {
  name = "S3VersionEnabled"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_VERSIONING_ENABLED"
  }
  depends_on = [aws_config_configuration_recorder.foo]
}
### Ensure versioning is enable - default behaviour 
resource "aws_config_remediation_configuration" "S3VersionEnabledRemediation" {
  config_rule_name = aws_config_config_rule.S3VersionEnabled.name
  resource_type    = "AWS::S3::Bucket"
  target_type      = "SSM_DOCUMENT"
  target_id        = "AWS-ConfigureS3BucketVersioning"
  target_version   = "1"

  parameter {
    name         = "AutomationAssumeRole"
    static_value = aws_iam_role.SecAutomationRole.arn
  }
  parameter {
    name           = "BucketName"
    resource_value = "RESOURCE_ID"
  }

  automatic                  = true
  maximum_automatic_attempts = 10
  retry_attempt_seconds      = 60

  execution_controls {
    ssm_controls {
      concurrent_execution_rate_percentage = 25
      error_percentage                     = 20
    }
  }
}