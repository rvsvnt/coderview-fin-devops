#!/bin/bash

# Variables
LAMBDA_FUNCTION_NAME="promote_db"
PRIMARY_RDS_INSTANCE_ID="primary-db"
SECONDARY_RDS_INSTANCE_ID="secondary-db"

# Simulate an RDS failover event
echo "Simulating RDS failover event..."
aws lambda invoke \
  --function-name $LAMBDA_FUNCTION_NAME \
  --payload '{
    "detail": {
      "SourceIdentifier": "'$PRIMARY_RDS_INSTANCE_ID'",
      "SourceArn": "arn:aws:rds:us-west-2:123456789012:db:'$SECONDARY_RDS_INSTANCE_ID'"
    }
  }' \
  output.txt

# Check Lambda function output
echo "Lambda function output:"
cat output.txt

# Verify that the secondary RDS is promoted to primary
echo "Verifying RDS instance status..."
SECONDARY_STATUS=$(aws rds describe-db-instances \
  --region us-west-2 \
  --db-instance-identifier $SECONDARY_RDS_INSTANCE_ID \
  --query 'DBInstances[0].DBInstanceStatus' \
  --output text)

if [ "$SECONDARY_STATUS" == "available" ]; then
  echo "Secondary RDS promoted to primary successfully."
else
  echo "Failed to promote secondary RDS to primary."
fi