# zip lambda code
data "archive_file" "zip_data_collection" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_src/data_collection/"
  output_path = "${path.module}/lambda_archives/collection.zip"
}

resource "aws_lambda_function" "data_collection_func" {
  filename         = "${path.module}/lambda_archives/collection.zip"
  function_name    = "unscramble_data_collection"
  role             = aws_iam_role.lambda_role.arn
  handler          = "main.lambda_handler"
  runtime          = "python3.9"
  depends_on       = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
  source_code_hash = filebase64sha256("${path.module}/lambda_archives/collection.zip")
  timeout          = 60

  layers = [
    aws_lambda_layer_version.requests_lambda_layer.arn,
    aws_lambda_layer_version.bs4_lambda_layer.arn,
  ]
}

resource "aws_lambda_function_event_invoke_config" "data_collection_config" {
  function_name                = aws_lambda_function.data_collection_func.function_name
  maximum_retry_attempts       = 0
}

resource "aws_lambda_layer_version" "requests_lambda_layer" {
  filename   = "${path.module}/lambda_layers/requests.zip"
  layer_name = "requests"

  compatible_runtimes = ["python3.9"]
}

resource "aws_lambda_layer_version" "bs4_lambda_layer" {
  filename   = "${path.module}/lambda_layers/beautifulsoup4.zip"
  layer_name = "beautifulsoup4"

  compatible_runtimes = ["python3.9"]
}