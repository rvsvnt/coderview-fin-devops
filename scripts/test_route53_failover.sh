#!/bin/bash

# Variables
PRIMARY_DNS="db.example.com"
SECONDARY_DNS="db-secondary.example.com"

# Simulate primary region failure by stopping the primary RDS instance
echo "Simulating primary region failure..."
aws rds stop-db-instance \
  --region us-east-1 \
  --db-instance-identifier primary-db

# Wait for Route 53 to detect the failure and route traffic to the secondary region
echo "Waiting for Route 53 to failover..."
sleep 300  # Wait 5 minutes for Route 53 health checks to trigger failover

# Verify DNS resolution
echo "Testing DNS resolution..."
PRIMARY_IP=$(dig +short $PRIMARY_DNS)
SECONDARY_IP=$(dig +short $SECONDARY_DNS)

if [ -z "$PRIMARY_IP" ] && [ -n "$SECONDARY_IP" ]; then
  echo "Failover successful. Traffic is routed to the secondary region."
else
  echo "Failover failed. Traffic is not routed to the secondary region."
fi

# Restore primary RDS instance
echo "Restoring primary RDS instance..."
aws rds start-db-instance \
  --region us-east-1 \
  --db-instance-identifier primary-db