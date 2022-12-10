resource "aws_ssm_parameter" "next_puzzle_id" {
  name      = "next_puzzle_id"
  type      = "String"
  value     = "1"
  overwrite = false

  lifecycle {
    ignore_changes = [value]
  }
}
