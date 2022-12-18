# REST API object
resource "aws_api_gateway_rest_api" "puzzle_retriever" {
  name        = "PuzzleRetriever"
  description = "API for getting puzzle information"
}

#######################################################
# puzzle retriever
#######################################################
resource "aws_api_gateway_resource" "puzzle_retriever_proxy" {
  rest_api_id = aws_api_gateway_rest_api.puzzle_retriever.id
  parent_id   = aws_api_gateway_rest_api.puzzle_retriever.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "puzzle_retriever_proxy" {
  rest_api_id   = aws_api_gateway_rest_api.puzzle_retriever.id
  resource_id   = aws_api_gateway_resource.puzzle_retriever_proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

# proxy resource can't match empty path at root of api, so need to configure same 
# thing for the root resource in the REST API object
resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = aws_api_gateway_rest_api.puzzle_retriever.id
  resource_id   = aws_api_gateway_rest_api.puzzle_retriever.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "puzzle_retriever_lambda" {
  rest_api_id = aws_api_gateway_rest_api.puzzle_retriever.id
  resource_id = aws_api_gateway_method.puzzle_retriever_proxy.resource_id
  http_method = aws_api_gateway_method.puzzle_retriever_proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.puzzle_retriever_func.invoke_arn
}

resource "aws_api_gateway_integration" "puzzle_retriever_lambda_root" {
  rest_api_id = aws_api_gateway_rest_api.puzzle_retriever.id
  resource_id = aws_api_gateway_method.proxy_root.resource_id
  http_method = aws_api_gateway_method.proxy_root.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.puzzle_retriever_func.invoke_arn
}

# allow api gateway to invoke lambda
resource "aws_lambda_permission" "allow_invoke_puzzle_retriever" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.puzzle_retriever_func.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.puzzle_retriever.execution_arn}/*/*"
}


#######################################################
# ID lister
#######################################################
resource "aws_api_gateway_resource" "list_puzzle_ids_proxy" {
  rest_api_id = aws_api_gateway_rest_api.puzzle_retriever.id
  parent_id   = aws_api_gateway_rest_api.puzzle_retriever.root_resource_id
  path_part   = "list_puzzles"
}

resource "aws_api_gateway_method" "list_puzzle_ids_proxy" {
  rest_api_id   = aws_api_gateway_rest_api.puzzle_retriever.id
  resource_id   = aws_api_gateway_resource.list_puzzle_ids_proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "list_puzzle_ids_lambda" {
  rest_api_id = aws_api_gateway_rest_api.puzzle_retriever.id
  resource_id = aws_api_gateway_method.list_puzzle_ids_proxy.resource_id
  http_method = aws_api_gateway_method.list_puzzle_ids_proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.list_puzzle_ids_func.invoke_arn
}

resource "aws_api_gateway_integration" "list_puzzle_ids_lambda_root" {
  rest_api_id = aws_api_gateway_rest_api.puzzle_retriever.id
  resource_id = aws_api_gateway_method.proxy_root.resource_id
  http_method = aws_api_gateway_method.proxy_root.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.list_puzzle_ids_func.invoke_arn
}

# allow api gateway to invoke lambda
resource "aws_lambda_permission" "allow_invoke_list_puzzle_ids" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.list_puzzle_ids_func.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.puzzle_retriever.execution_arn}/*/*"
}


#######################################################
# deployment
#######################################################
resource "aws_api_gateway_deployment" "scrambler_api_deployment" {
  depends_on = [
    aws_api_gateway_integration.puzzle_retriever_lambda,
    aws_api_gateway_integration.puzzle_retriever_lambda_root,
    aws_api_gateway_integration.list_puzzle_ids_lambda,
    aws_api_gateway_integration.list_puzzle_ids_lambda_root
  ]

  rest_api_id = aws_api_gateway_rest_api.puzzle_retriever.id
  stage_name  = "puzzle_retriever"
}
