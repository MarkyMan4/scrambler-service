resource "aws_cloudwatch_event_rule" "data_collection_schedule" {
  name                = "unscramble_data_collection_schedule"
  description         = "Schedule for unscramble data collection"
  schedule_expression = "cron(*/5 * * * ? *)"
}

resource "aws_cloudwatch_event_target" "schedule_data_collection_lambda" {
  rule      = aws_cloudwatch_event_rule.data_collection_schedule.name
  target_id = "data_collection_func"
  arn       = aws_lambda_function.data_collection_func.arn
}

resource "aws_lambda_permission" "allow_events_bridge_to_run_collection_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.data_collection_func.function_name
  principal     = "events.amazonaws.com"
}
