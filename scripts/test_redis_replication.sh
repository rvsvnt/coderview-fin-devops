#!/bin/bash

# Variables
PRIMARY_REDIS_ENDPOINT="primary-redis-endpoint"
SECONDARY_REDIS_ENDPOINT="secondary-redis-endpoint"

# Write data to primary Redis
echo "Writing data to primary Redis..."
redis-cli -h $PRIMARY_REDIS_ENDPOINT SET test_key "test_value"

# Read data from secondary Redis
echo "Reading data from secondary Redis..."
SECONDARY_VALUE=$(redis-cli -h $SECONDARY_REDIS_ENDPOINT GET test_key)

if [ "$SECONDARY_VALUE" == "test_value" ]; then
  echo "Redis replication is working."
else
  echo "Redis replication failed."
fi