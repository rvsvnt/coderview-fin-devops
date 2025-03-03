from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
import redis
import logging
import os

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)

# Read environment variables for database and Redis
db_user = os.getenv('DB_USER', 'user')
db_password = os.getenv('DB_PASSWORD', 'password')
db_host = os.getenv('DB_HOST', 'rds-endpoint')
db_name = os.getenv('DB_NAME', 'transactions')

redis_host = os.getenv('REDIS_HOST', 'redis-endpoint')
redis_port = int(os.getenv('REDIS_PORT', '6379'))

# Configure RDS (PostgreSQL)
app.config['SQLALCHEMY_DATABASE_URI'] = f'postgresql://{db_user}:{db_password}@{db_host}:5432/{db_name}'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

# Configure Redis
redis_client = redis.Redis(host=redis_host, port=redis_port, db=0)

# Define the Transaction model
class Transaction(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    amount = db.Column(db.Float, nullable=False)
    sender = db.Column(db.String(100), nullable=False)
    receiver = db.Column(db.String(100), nullable=False)
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)

    def __repr__(self):
        return f"Transaction(id={self.id}, amount={self.amount}, sender={self.sender}, receiver={self.receiver})"

# Create the database
with app.app_context():
    db.create_all()

# Endpoint to process a transaction
@app.route('/process_transaction', methods=['POST'])
def process_transaction():
    data = request.get_json()
    amount = data.get('amount')
    sender = data.get('sender')
    receiver = data.get('receiver')

    # Validate input
    if not amount or not sender or not receiver:
        logger.error("Missing required fields")
        return jsonify({"error": "Missing required fields"}), 400

    # Check Redis cache for duplicate transactions
    cache_key = f"transaction:{sender}:{receiver}:{amount}"
    if redis_client.get(cache_key):
        logger.warning("Duplicate transaction detected")
        return jsonify({"error": "Duplicate transaction"}), 400

    # Create a new transaction
    transaction = Transaction(amount=amount, sender=sender, receiver=receiver)
    db.session.add(transaction)
    db.session.commit()

    # Cache the transaction in Redis
    redis_client.set(cache_key, "processed", ex=60)  # Cache for 60 seconds

    logger.info(f"Transaction processed successfully: {transaction}")
    return jsonify({"message": "Transaction processed successfully", "transaction_id": transaction.id}), 201

# Endpoint to get all transactions
@app.route('/transactions', methods=['GET'])
def get_transactions():
    transactions = Transaction.query.all()
    logger.info("Retrieved all transactions")
    return jsonify([{
        "id": t.id,
        "amount": t.amount,
        "sender": t.sender,
        "receiver": t.receiver,
        "timestamp": t.timestamp
    } for t in transactions])

if __name__ == '__main__':
    app.run(debug=True)