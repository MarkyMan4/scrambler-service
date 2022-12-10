resource "aws_dynamodb_table" "unscramble_table" {
  name           = "UnscramblePuzzles"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "PuzzleId"

  attribute {
    name = "PuzzleId"
    type = "N"
  }
}
