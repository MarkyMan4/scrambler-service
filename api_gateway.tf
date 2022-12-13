resource "aws_api_gateway_rest_api" "puzzle_retriever" {
  name        = "PuzzleRetriever"
  description = "API for getting puzzle information"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.puzzle_retriever.id}"
  parent_id   = "${aws_api_gateway_rest_api.puzzle_retriever.root_resource_id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = "${aws_api_gateway_rest_api.puzzle_retriever.id}"
  resource_id   = "${aws_api_gateway_resource.proxy.id}"
  http_method   = "ANY"
  authorization = "NONE"
}