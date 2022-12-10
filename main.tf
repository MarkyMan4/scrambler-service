# create IAM role
resource "aws_iam_role" "lambda_role" {
  name               = "unscramble_data_collection_lambda_role"
  assume_role_policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": "sts:AssumeRole",
                "Principal": {
                "Service": "lambda.amazonaws.com"
                },
                "Effect": "Allow",
                "Sid": ""
            }
        ]
    }
    EOF
}

# create policy which will apply to role
resource "aws_iam_policy" "iam_policy_for_lambda" {
  name        = "aws_iam_policy_for_terraform_aws_lambda_role"
  path        = "/"
  description = "AWS IAM Policy for managing aws lambda role"
  policy      = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": [
       "logs:CreateLogGroup",
       "logs:CreateLogStream",
       "logs:PutLogEvents"
     ],
     "Resource": "arn:aws:logs:*:*:*",
     "Effect": "Allow"
   }
 ]
}
EOF
}

# attach policy to role
resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda.arn
}

# zip lambda code
data "archive_file" "zip_data_collection" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_src/data_collection/"
  output_path = "${path.module}/lambda_src/data_collection/collection.zip"
}

resource "aws_lambda_function" "data_collection_func" {
  filename         = "${path.module}/lambda_src/data_collection/collection.zip"
  function_name    = "unscramble_data_collection"
  role             = aws_iam_role.lambda_role.arn
  handler          = "main.lambda_handler"
  runtime          = "python3.9"
  depends_on       = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
  source_code_hash = filebase64sha256("${path.module}/lambda_src/data_collection/collection.zip")
  timeout          = 60

  layers = [
    aws_lambda_layer_version.requests_lambda_layer.arn,
    aws_lambda_layer_version.bs4_lambda_layer.arn,
  ]
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
