provider "aws" {
  region = var.region

  default_tags {
    tags = {
      project     = "jedi-holocron"
      environment = var.environment
    }
  }
}

##################################################
# S3
##################################################

module "s3" {
  source = "../../modules/s3"

  bucket_name = "jedi-holocron-storage"
  environment = var.environment
}

##################################################
# Lambda
##################################################

module "lambda_manifest" {
  source = "../../modules/lambda"

  environment = var.environment

  lambda_function_name        = "JediHolocronManifestLambda"
  lambda_function_description = "This is an AWS Lambda function to process manifest files"
  source_dir                  = "manifest"

  bucket_name               = module.s3.bucket_name
  s3_policy_arn             = module.s3.s3_policy_arn
  api_gateway_execution_arn = module.api_gateway.api_gateway_execution_arn
  cmk_policy_arn            = module.cmk.cmk_policy_arn

  environment_variables = {
    AWS_S3_BUCKET_NAME = module.s3.bucket_name
    AWS_CMK_ARN        = module.cmk.cmk_arn
    USERNAME           = var.username
    PASSWORD           = var.password
  }

  password = var.password
}

module "lambda_retrieve" {
  source = "../../modules/lambda"

  environment = var.environment

  lambda_function_name        = "JediHolocronRetrieveLambda"
  lambda_function_description = "This is an AWS Lambda function for retrieving data"
  source_dir                  = "retrieve"

  bucket_name               = module.s3.bucket_name
  s3_policy_arn             = module.s3.s3_policy_arn
  api_gateway_execution_arn = module.api_gateway.api_gateway_execution_arn
  cmk_policy_arn            = module.cmk.cmk_policy_arn

  environment_variables = {
    AWS_S3_BUCKET_NAME = module.s3.bucket_name
    AWS_CMK_ARN        = module.cmk.cmk_arn
    USERNAME           = var.username
  }

  password = var.password
}

##################################################
# CMK
##################################################

module "cmk" {
  source = "../../modules/cmk"

  environment         = var.environment
  cmk_description     = "This is CMK for Jedi Holocron to encrypt data at rest"
  enable_key_rotation = true
}

##################################################
# API Gateway
##################################################

module "api_gateway" {
  source = "../../modules/api_gateway"

  api_gateway_name = "JediHolocronAPI"
  environment      = var.environment
  integrations = {
    manifest = {
      integration_route_key   = "manifest"
      integration_method      = "POST"
      integration_uri         = module.lambda_manifest.invoke_arn
      integration_description = "This is the integration for the /manifest route"
    }
    retrieve = {
      integration_route_key   = "retrieve"
      integration_method      = "POST"
      integration_uri         = module.lambda_retrieve.invoke_arn
      integration_description = "This is the integration for the /retrieve route"
    }
  }
}
