#!/usr/bin/env bash
# simple script to create s3 bucket and dynamoDB table. 
# Intentionally this script is minimal. If interested do exercises to improve your script, Read comments for exercises.

BUCKET="remote-state-storage"
DYNAMODB_TABLE="remote-state-lock"

# Create S3 bucket
# Exercise 1: Add conditions to check if bucket already exists. Create only if S3 bucket doesnt exist.
# Exercise 2: below CLI commands work well with us-east-1 region, for other regions look up locationConstraint 
aws s3api create-bucket --bucket ${BUCKET} --region "us-east-1"
aws s3api put-bucket-versioning --bucket ${BUCKET} --versioning-configuration Status=Enabled
aws s3api put-bucket-encryption --bucket ${BUCKET} \
--server-side-encryption-configuration '{ "Rules": [{ "ApplyServerSideEncryptionByDefault": { "SSEAlgorithm": "AES256" }}]}'

echo "S3 ${BUCKET} is created"

echo "create dynamodb_table ${DYNAMODB_TABLE}"
# Exercise 4: add condition to check if dynamoDB table exists, create only if it doesnt exist
aws dynamodb create-table --table-name ${DYNAMODB_TABLE} \
      --attribute-definitions AttributeName=LockID,AttributeType=S \
      --key-schema AttributeName=LockID,KeyType=HASH \
      --provisioned-throughput ReadCapacityUnits=20,WriteCapacityUnits=20

# Exercise 5: instead of sleep, write condition to check if status of table is ACTIVE . 
sleep 60
STATUS=$(aws dynamodb describe-table --table-name ${DYNAMODB_TABLE} --output text --query 'Table.TableStatus')
echo "DynamoDB table status: $STATUS"

terraform init -backend-config="bucket=${BUCKET}" -backend=true -upgrade