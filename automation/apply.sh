#!/bin/bash
wait_for_localstack() {
    env
    echo "Waiting for LocalStack to be ready..."
    until nc -z localstack 4566; do
        echo "LocalStack is not reachable yet, waiting..."
        sleep 5
    done
    echo "LocalStack is ready."
}

# Wait for LocalStack
wait_for_localstack

# Initialize Terraform
terraform init

# Apply Terraform configuration
terraform apply -auto-approve

# Check the exit status of the previous command
if [ $? -eq 0 ]; then
    echo "Terraform apply successful"
    echo ">>> extracting first lambda URL from terraform output"
    first=$(terraform output -json | jq -r '.first_lambda_url.value' )
    echo ">>> invoking first lambda:"
    curl -X GET $first
    echo ">>> extracting second lambda URL from terraform output"
    second=$(terraform output -json | jq -r '.second_lambda_url.value' )
    echo ">>> running second lambda with 'Authorization: 946684800' header"
    second_respond=$(curl -X GET $second -H "Authorization: 946684800")
    echo ">>> extracting the value of the secret from the second lambda's response"
    if [[ $second_respond =~ the\ secret\ is:\ (.*) ]]; then
        secret_value="${BASH_REMATCH[1]}"
        echo ">>> extracted secret: '$secret_value'"
    else
        echo "No secret value found."
    fi
else
    echo "Terraform apply failed"
    exit 1
fi

