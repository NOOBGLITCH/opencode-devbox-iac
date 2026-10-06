# ---------- 1. IAM User ----------
resource "aws_iam_user" "dev_user" {
  name = "tf-dev-user"
  path = "/"

  tags = {
    ManagedBy = "terraform"
  }
}

# ---------- 2. Access Key (optional - for CLI/SDK access) ----------
resource "aws_iam_access_key" "dev_user_key" {
  user = aws_iam_user.dev_user.name
}

# ---------- 3. IAM Policy ----------
resource "aws_iam_policy" "full_infra_access" {
  name        = "FullEC2S3VPCAccess"
  description = "Full control over EC2, S3 and VPC resources"
  policy      = data.aws_iam_policy_document.full_infra_access.json
}

# ---------- 4. Policy Attachment ----------
resource "aws_iam_user_policy_attachment" "dev_user_attach" {
  user       = aws_iam_user.dev_user.name
  policy_arn = aws_iam_policy.full_infra_access.arn
}