### Config role
resource "aws_iam_role" "this" {
  name               = "my-awsconfig-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "awsconfig_managed_policy" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

data "aws_iam_policy_document" "p" {
  statement {
    effect = "Allow"
    actions = [
      "config:Put*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "p" {
  name   = "my-awsconfig-policy"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.p.json
}


### Remediation role
resource "aws_iam_role" "SecAutomationRole" {
  name               = "SecAutomation"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "ssm.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

### Managed Policy
data "aws_iam_policy" "awsssm_service_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMAutomationRole"
}


### Policy attachments
resource "aws_iam_role_policy_attachment" "awsssm_service_role_policy_attach" {
  role       = aws_iam_role.SecAutomationRole.name
  policy_arn = data.aws_iam_policy.awsssm_service_policy.arn
}

### We need permissions to enable encryption - poc s3FullAccess
### Deploymet in prod must use minimum permissions required
resource "aws_iam_role_policy_attachment" "awss3_service_role_policy_attach" {
  role       = aws_iam_role.SecAutomationRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}