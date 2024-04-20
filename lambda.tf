resource "aws_iam_role" "lambda_role" {
  name               = "lambda-execution-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "lambda_role_policy_attachment" {
  name       = "lambda-role-policy-attachment"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "first" {
  function_name = "docker1st"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  package_type  = "Image"
  image_uri     = "docker.io/jonathanpick/first-lambda:v1"
}

resource "aws_lambda_function" "second" {
  function_name = "docker2nd"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  package_type  = "Image"
  image_uri     = "docker.io/jonathanpick/second-lambda:v1"
}
