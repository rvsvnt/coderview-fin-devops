#!/bin/bash

# Variables
PRIMARY_REGION="us-east-1"
SECONDARY_REGION="us-west-2"
PRIMARY_RDS_INSTANCE_ID="primary-db"
SECONDARY_RDS_INSTANCE_ID="secondary-db"

# Promote the secondary RDS to primary
echo "Promoting secondary RDS in $SECONDARY_REGION to primary..."
aws rds promote-read-replica \
  --region $SECONDARY_REGION \
  --db-instance-identifier $SECONDARY_RDS_INSTANCE_ID

# Wait for promotion to complete
echo "Waiting for promotion to complete..."
aws rds wait db-instance-available \
  --region $SECONDARY_REGION \
  --db-instance-identifier $SECONDARY_RDS_INSTANCE_ID

echo "Failover complete. Secondary RDS is now primary."