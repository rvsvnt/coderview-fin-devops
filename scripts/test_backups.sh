#!/bin/bash

# Variables
BACKUP_BUCKET="rds-backup-bucket"
RDS_INSTANCE_ID="primary-db"

# List available backups in the S3 bucket
echo "Listing backups in S3 bucket..."
aws s3 ls s3://$BACKUP_BUCKET/

# Verify the latest backup
LATEST_BACKUP=$(aws rds describe-db-snapshots \
  --region us-east-1 \
  --db-instance-identifier $RDS_INSTANCE_ID \
  --query 'DBSnapshots[-1].DBSnapshotIdentifier' \
  --output text)

if [ -n "$LATEST_BACKUP" ]; then
  echo "Latest backup: $LATEST_BACKUP"
else
  echo "No backups found."
fi