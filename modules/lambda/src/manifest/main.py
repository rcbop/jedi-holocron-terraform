""" This module contains the main Lambda function code. """
import base64
import json
import os

import boto3
from botocore.exceptions import ClientError

s3_bucket_name = os.getenv("AWS_S3_BUCKET_NAME")
cmk_arn = os.getenv("AWS_CMK_ARN")

s3_client = boto3.client('s3')
kms_client = boto3.client('kms')

file_key = "manifest.b64.enc"

def lambda_handler(event, context):
    """ Lambda function handler. """
    try:
        print("Checking basic auth")
        if not is_basic_auth(event):
            return {
                "statusCode": 401,
                "body": json.dumps({"Message": "Unauthorized"})
            }

        manifest = json.loads(event["body"])
        print("downloading previous manifest from S3")
        previous_manifest = download_previous_manifest()
        if previous_manifest:
            print("decrypting previous manifest")
            decrypted_previous_manifest = decrypt_manifest(previous_manifest)
            print("merging manifests")
            manifest = merge_manifests(decrypted_previous_manifest, manifest)
        print(f"manifest entries size: {len(manifest)}")
        print("encrypting manifest")
        encrypted_manifest = encrypt_manifest(manifest)
        print("uploading manifest to S3")
        upload_manifest_to_s3(encrypted_manifest)

        response = {
            'statusCode': 200,
            'body': json.dumps({"Message": "OK"})
        }
        return response
    except Exception as e:
        print(f"Error processing manifest: {str(e)}")
        response = {
            'statusCode': 500,
            'body': json.dumps({"Message": "Error"})
        }
        return response

def download_previous_manifest():
    """ Download the previous manifest from S3. """
    try:
        response = s3_client.get_object(Bucket=s3_bucket_name, Key=file_key)
        previous_manifest = response['Body'].read().decode('utf-8')
        return previous_manifest
    except ClientError as e:
        if e.response['Error']['Code'] == 'NoSuchKey':
            print("No previous manifest found")
            return ""
        raise

def decrypt_manifest(encrypted_manifest):
    """ Decrypt the manifest using the CMK. """
    if not encrypted_manifest:
        raise ValueError("Encrypted manifest is empty")

    try:
        decoded_manifest = base64.b64decode(encrypted_manifest)
        decrypted_manifest = kms_client.decrypt(CiphertextBlob=decoded_manifest)['Plaintext'].decode('utf-8')
        return decrypted_manifest

    except ClientError as e:
        print(f"Error decrypting manifest: {str(e)}")
        raise

def merge_manifests(previous_manifest, new_manifest: dict):
    """ Merge the previous and new manifests. """
    previous_manifest = json.loads(previous_manifest)
    previous_manifest.update(new_manifest)
    return previous_manifest

def encrypt_manifest(manifest):
    """ Encrypt the manifest using the CMK. """
    try:
        encrypted_manifest = kms_client.encrypt(
            KeyId=cmk_arn,
            Plaintext=json.dumps(manifest)
        )['CiphertextBlob']
        return base64.b64encode(encrypted_manifest).decode('utf-8')
    except ClientError as e:
        print(f"Error encrypting manifest: {str(e)}")
        raise

def upload_manifest_to_s3(encrypted_manifest):
    """ Upload the encrypted manifest to S3. """
    try:
        s3_client.put_object(Bucket=s3_bucket_name, Key=file_key, Body=encrypted_manifest)
    except ClientError as e:
        print(f"Error uploading manifest to S3: {str(e)}")
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
