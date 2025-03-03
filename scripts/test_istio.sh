#!/bin/bash

# Variables
FLASK_ENDPOINT="http://flask-app.example.com"

# Send a test transaction
echo "Sending test transaction..."
curl -X POST $FLASK_ENDPOINT/process_transaction \
  -H "Content-Type: application/json" \
  -d '{"amount": 100.0, "sender": "Alice", "receiver": "Bob"}'

# Verify the transaction
echo "Verifying transaction..."
curl $FLASK_ENDPOINT/transactions