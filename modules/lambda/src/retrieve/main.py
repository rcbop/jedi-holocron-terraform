""" Lambda function to retrieve a manifest entry """
import base64
import json
import os

import boto3
from botocore.exceptions import ClientError

s3 = boto3.client("s3")
kms = boto3.client("kms")

bucket_name = os.getenv("AWS_S3_BUCKET_NAME")
cmk_arn = os.getenv("AWS_CMK_ARN")

file_key = "manifest.b64.enc"

def lambda_handler(event, context):
    """ Lambda handler function """
    try:
        print("Checking basic auth")
        if not is_basic_auth(event):
            return {
                "statusCode": 401,
                "body": json.dumps({"Message": "Unauthorized"})
            }

        print("Parsing request body")
        body = json.loads(event["body"])
        jedi_id = body["id"]
        print(f"Retrieving manifest entry with ID: {jedi_id}")

        print("Downloading manifest")
        response = s3.get_object(Bucket=bucket_name, Key=file_key)
        manifest_data = response['Body'].read().decode('utf-8')

        print("Decrypting manifest")
        decrypted_manifest_data = decrypt_manifest(manifest_data)

        print("Parsing manifest")
        manifest = json.loads(decrypted_manifest_data)

        if jedi_id in manifest:
            return {
                'statusCode': 200,
                'body': json.dumps(manifest[jedi_id])
            }
        else:
            return {
                'statusCode': 404,
                'body': 'Entry not found'
            }
    except Exception as e:
        print(f"Error retrieving manifest: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({"Message": "Error"})
        }

def decrypt_manifest(encrypted_manifest):
    """ Decrypt the manifest using the CMK. """
    if not encrypted_manifest:
        raise ValueError("Encrypted manifest is empty")

    try:
        decoded_manifest = base64.b64decode(encrypted_manifest)
        decrypted_manifest = kms.decrypt(CiphertextBlob=decoded_manifest)['Plaintext'].decode('utf-8')
        return decrypted_manifest

    except ClientError as e:
        print(f"Error decrypting manifest: {str(e)}")
        raise

def is_basic_auth(event):
    """Extracts the Authorization header and performs basic authentication check"""
    auth_header = event.get('headers', {}).get('authorization')
    if not auth_header:
        return False
    encoded_credentials = auth_header.split(' ')[1]
    decoded_credentials = base64.b64decode(encoded_credentials).decode('utf-8')
    username, password = decoded_credentials.split(':')
    return username == os.getenv('USERNAME') and password == os.getenv('PASSWORD')
