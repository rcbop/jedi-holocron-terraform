
# Jedi Holocron Terraform

The Jedi Holocron project is a Terraform exercise that aims to manage infrastructure for a Jedi information system. The project is organized into several Terraform files and modules, with a structure that includes a main terraform file in (`env/dev/jedi_holocron.tf`) and terraform modules in the modules directory.

## Table of Contents

- [Jedi Holocron Terraform](#jedi-holocron-terraform)
  - [Table of Contents](#table-of-contents)
  - [Usage](#usage)
  - [Endpoints](#endpoints)
  - [Manifest Encryption and Handling](#manifest-encryption-and-handling)
  - [Basic Authentication](#basic-authentication)
  - [Project Overview](#project-overview)
    - [CMK Module](#cmk-module)
    - [S3 Bucket Module](#s3-bucket-module)
    - [Lambda Module](#lambda-module)
    - [API Gateway Module](#api-gateway-module)


## Usage

To use the Jedi Holocron Terraform project, follow these steps:

1. Clone this repository:

Clone this repository:

```bash
git clone https://github.com/your-username/jedi-holocron-terraform.git
cd jedi-holocron-terraform
```

2. Initialize Terraform:

```bash
cd env/dev
terraform init
```

3. Apply the Terraform configuration:

```bash
terraform apply
```

to change the password and username, use the following command:

```bash
terraform apply -var="username=luke" -var="password=skywalker"
```

4. Confirm the changes and let Terraform provision the infrastructure.

## Endpoints
The API Gateway exposes the following endpoints:

- POST /manifest: Allows users to upload Jedi information in the form of a dictionary. The request body structure is as follows:

```json
{
    "98721": {
        "name": "Yoda",
        "planet": "Dagobah",
        "power_level": 90
    },
    "54832": {
        "name": "Obi-Wan Kenobi",
        "planet": "Stewjon",
        "power_level": 85
    },
    "12345": {
        "name": "Mace Windu",
        "planet": "Haruun Kal",
        "power_level": 87
    }
}
```

- POST /retrieve: Retrieves information about a Jedi based on the provided ID. The request body structure is as follows:

```json
{
    "id": "51234"
}
```

Both endpoints are protected with basic authentication. To make a request using curl, use the following example:

```bash
curl -X POST -H "Authorization: Basic bHVrZTpza3l3YWxrZXI=" -H "Content-Type: application/json" -d '{"id": "51234"}' https://$API_GATEWAY_URL/retrieve
```

## Manifest Encryption and Handling

The Jedi manifest is encrypted with the CMK key before being stored in the S3 bucket. When the `/retrieve` route is called, the manifest is downloaded, decrypted, and filtered for the correct information. When the `POST /manifests` endpoint is called, the previous encrypted version of the manifest is downloaded from the S3 bucket, decrypted, merged with the manifest passed in the request body, encrypted again, and then uploaded to the S3 bucket, overwriting the previous version.

The source code for both the Lambda functions can be found in the [modules/lambda/src](./modules/lambda/src/) directory.

## Basic Authentication

The basic authentication protecting the endpoints requires a username and password. These credentials can be defined during the Terraform apply process by passing the username and password variables. They are then provided to the Lambda function via environment variables.

## Project Overview

The following diagram shows the infrastructure created by the Jedi Holocron project:

![Jedi Holocron Infrastructure](./docs/jedi-holocron-infra.png)

The project consists of several modules:

### CMK Module

Located in [modules/cmk](./modules/cmk/). Manages the provisioning of a Customer Master Key (CMK) for encryption purposes.

| **Input Variable**    | **Description**                | **Type** | **Default**              |
| --------------------- | ------------------------------ | -------- | ------------------------ |
| `cmk_description`     | The description of the CMK     | `string` | `"This is a sample CMK"` |
| `enable_key_rotation` | Whether to enable key rotation | `bool`   | `true`                   |
| `environment`         | The environment for the CMK    | `string` | `"DEV"`                  |

| **Output**       | **Description**                           | **Example**                                                                     |
| ---------------- | ----------------------------------------- | ------------------------------------------------------------------------------- |
| `cmk_arn`        | The ARN of the created CMK                | `"arn:aws:kms:us-east-1:123456789012:key/abcdefgh-1234-5678-abcd-1234567890ab"` |
| `cmk_id`         | The key ID of the created CMK             | `"abcdefgh-1234-5678-abcd-1234567890ab"`                                        |
| `cmk_policy_arn` | The ARN of the created IAM policy for CMK | `"arn:aws:iam::123456789012:policy/CMKPolicy-DEV"`                              |

### S3 Bucket Module

Located in [modules/s3](./modules/s3/). Handles the creation of an S3 bucket for storing encrypted Jedi manifests.

| **Input Variable**           | **Description**                | **Type** | **Default** |
|------------------------------|--------------------------------|----------|-------------|
| `bucket_name`                | The name of the S3 bucket       | `string` |             |
| `environment`                | The environment to deploy to    | `string` | `"DEV"`      |

| **Output**                   | **Description**                  | **Example**                            |
|------------------------------|----------------------------------|----------------------------------------|
| `bucket_name`                | The name of the created S3 bucket | `"jedi-manifests-bucket"`              |
| `bucket_arn`                 | The ARN of the created S3 bucket  | `"arn:aws:s3:::jedi-manifests-bucket"` |
| `s3_policy_arn`              | The ARN of the created IAM policy for S3 bucket | `"arn:aws:iam::123456789012:policy/S3Policy-DEV"` |

### Lambda Module

Located in [modules/lambda](./modules/lambda/). Provisions Lambda functions and their associated resources for handling Jedi manifest operations.

Here is a Markdown table summarizing the inputs and outputs for the provided Terraform module:

| **Input Variable**               | **Description**                               | **Type**      | **Default**  |
|----------------------------------|-----------------------------------------------|---------------|--------------|
| `lambda_function_name`           | The name of the Lambda function               | `string`      |              |
| `lambda_function_description`    | The description of the Lambda function        | `string`      | `"This is a sample Lambda function"` |
| `source_dir`                     | The source directory for the Lambda function  | `string`      |              |
| `environment`                    | The environment to deploy to                  | `string`      | `"DEV"`      |
| `api_gateway_execution_arn`      | The ARN of the API Gateway execution           | `string`      |              |
| `environment_variables`          | The environment variables for the Lambda function | `map(string)` | `{}`         |
| `password`                       | The password for the Lambda function          | `string`      | (Sensitive)  |
| `s3_policy_arn`                  | The ARN of the S3 policy                      | `string`      |              |
| `cmk_policy_arn`                 | The ARN of the CMK policy                     | `string`      |              |
| `bucket_name`                    | The name of the S3 bucket                     | `string`      |              |

| **Output**                       | **Description**                               | **Example**                           |
|----------------------------------|-----------------------------------------------|---------------------------------------|
| `invoke_arn`                     | The ARN used to invoke the Lambda function    | `"arn:aws:lambda:us-east-1:123456789012:function:MyLambdaFunction-DEV"` |

###  API Gateway Module

Located in [modules/api_gateway](./modules/api_gateway/). Sets up an API Gateway with two protected endpoints: POST /manifest and POST /retrieve.

| **Input Variable** | **Description**                      | **Type** | **Example**       |
| ------------------ | ------------------------------------ | -------- | ----------------- |
| `api_gateway_name` | The name of the API Gateway          | `string` | `"jedi-api"`      |
| `integrations`     | The integrations for the API Gateway | `map`    | See example below |
| `environment`      | The environment for the API Gateway  | `string` | `"production"`    |

**Example of `integrations` Map:**

```hcl
integrations = {
  example_integration = {
    integration_description = "Description of the integration"
    integration_method      = "POST"
    integration_uri         = "arn:aws:lambda:us-east-1:123456789012:function:example-lambda"
    integration_route_key   = "example-route"
  }
}
```

| **Output**                  | **Description**                              | **Example**                                                                            |
| --------------------------- | -------------------------------------------- | -------------------------------------------------------------------------------------- |
| `api_endpoint`              | The endpoint URL of the created API Gateway  | `"https://abcdefghi.execute-api.us-east-1.amazonaws.com/production"`                   |
| `api_gateway_execution_arn` | The execution ARN of the created API Gateway | `"arn:aws:execute-api:us-east-1:123456789012:abcdefghi/production/POST/example-route"` |




Feel free to explore the Jedi Holocron project! May the Force be with you.