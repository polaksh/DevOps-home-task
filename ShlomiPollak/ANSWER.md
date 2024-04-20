# Shlomi Pollak

## Code
My Terraform code creates:
* 2 lambda functions using the assignment's docker images [jonathanpick/first-lambda:v1](https://hub.docker.com/r/jonathanpick/first-lambda) and [jonathanpick/second-lambda:v1](https://hub.docker.com/r/jonathanpick/second-lambda)
* IAM role for the above lambda functions which allows `sts:AssumeRole` to the `lambda.amazonaws.com` service
* API Gateway, pretty much as was configured by the original code of the assignment, 
  however, I duplicated the below resources, so that the API Gateway will be able to serve both lambdas :
  * `aws_api_gateway_resource`
  * `aws_api_gateway_method`
  * `aws_api_gateway_integration`
  * `aws_lambda_permission`
* `output.tf` with the following fields:
  * `api_invoke_url` - for the deployment invokation URL
  * `rest_api_id` - for the rest API id
  * `first_lambda_url` - for the invocation url of the first lambda
  * `second_lambda_url` - for the invocation url of the second lambda
* docker-compose file for bootstrapping LocalStack, and automating everything as requested in the [Bonus Challenge](../Readme.md)



## Execution

### Disclaimer
At first I ran everything from my laptop, the [docker-compose.yml](../docker-compose.yml) only contained the LocalStack container
the `terrafrom apply` was made from my laptop as weel as all `curl` commands listed below in the [Results](#results) section

### Results
After applying the Terraform configuration ***locally***, I got two Lambda functions,
the `aws_lambda_function` resources are pulling their implementation from the publicly available docker images
which means I now have:
* [jonathanpick/first-lambda:v1](https://hub.docker.com/r/jonathanpick/first-lambda) for the first lambda:
  * the url to invoke this lambda while using LocalStack can be obtained from the `first_lambda_url` output.
  * the full curl command using the above terrafrom output is:
    ```bash
    curl -X GET http://localhost:4566/restapis/of5jex5h89/test/_user_request_/first
    ```
  * the following is the output:
    ```json
    {
      "statusCode": 200, 
      "body": "The Authorization header token is the epoch value of 01.01.2000 12:00:00 AM GMT."
    }
  ```
* [jonathanpick/second-lambda:v1](https://hub.docker.com/r/jonathanpick/second-lambda) for the second lambda:
  * the url to invoke this lambda while using LocalStack can be obtained from the `second_lambda_url` output.
  * the full curl command using the above terrafrom output is:
    ```bash
    curl -X GET http://localhost:4566/restapis/of5jex5h89/test/_user_request_/second
    ```
  * the following is the output **when no __Authorization__ header is provided**:
    ```json
    {
        "statusCode": 400, 
        "body": "Authorization: Header not found or does not match."
    }
    ```
  * according to the hint from the [first](../output.tf) lambda's output, when running the second lambda
    again using the correct header with:
    ```bash
    curl -X GET http://localhost:4566/restapis/of5jex5h89/test/_user_request_/second -H "Authorization: 946684800"
    ```
    provides the output:
    ```json
    {
        "statusCode": 200,
        "body": "Congratulations! You have successfully authorized the request, the secret is: Null."
    }
    ```

## Automation
After runing the docker-compose.yml with only localstack and running terraform from my laptop to achieve the [above](#execution),
I made the following modifications to automate the whole process:
* in the [docker-compose.yaml](../docker-compose.yml) I added a network `my-network` for both containers to communicate
* in the [docker-compose.yaml](../docker-compose.yml) I added another container called `terraform` to run everything, this container
will have all the code directory mounted into it and it will `chmod` the below `apply.sh` file to make it executable and will copy it to the working directory
* in the [provider.tf](../provider.tf) I replaced all `http://localhost:4566` to `http://localstack:4566` 
* in the [output.tf](../output.tf) I replaced all `http://localhost:4566` to `http://localstack:4566` 
* I added a new folder called `automation`, inside I put the following files:
  * `Dockerfile` - I tried to used the Terraform image to run `terraform init` and `terraform apply -auto-approve` but i couldn't make the `terraform` container wait for the `localstack` container... 
  to work around that i created this `Dockerfile` and as a convenience used an `ubuntu` image to insall terraform and other package to make it easy for me to automate the process
  * `apply.sh` - a bash script to automate everything, this script:
    1. wait until `localstack` is up
    2. runs `terrafrom init`
    3. runs `terraform apply -auto-approve`
    4. once terraform finishes, it extract the first lambda url from the terraform output and `curl` to it exposing the hint
    5. extract the second lambda url from the terraform output and `curl` to it along the the `Authorization: 946684800` header
    6. extract the secret from the response and print it
* to run the above goodness I executed a simple `docker compose up` whose logs can be found [here](./logs.log)
  ***please note:*** all lines the `apply.sh` script prints are starting with `>>>`