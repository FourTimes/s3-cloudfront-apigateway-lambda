resource "aws_s3_bucket" "main" {
  bucket = "${var.project}-${var.environment}-bucket"
  acl    = "private"
  policy = data.aws_iam_policy_document.bucket_policy.json
  website {
    index_document = "index.html"
    error_document = "error.html"
  }
  versioning {
    enabled    = true
  }

  force_destroy = false
  tags          = merge(map("Name", "${var.project}-${var.environment}-bucket"), var.additional_tags)
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid = "AllowReadFromAll"
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "arn:aws:s3:::${var.project}-${var.environment}-bucket/*",
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

