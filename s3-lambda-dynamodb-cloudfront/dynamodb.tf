resource "aws_dynamodb_table" "tl" {
  name           = "${var.project}-${var.environment}-dynamodb-CustomerProfile"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "CustomerId"
  attribute {
    name = "CustomerId"
    type = "S"
  }
  tags = merge(map("Name", "${var.project}-${var.environment}-dynamodb"), var.additional_tags)
}
