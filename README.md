# **Financial Transaction Processing System**

## **Overview**
The **Financial Transaction Processing System** is a **highly available, multi-region, cloud-native application** designed to handle **real-time financial transactions** while ensuring **strict data consistency, security, and disaster recovery**. The system is built using **Flask (Python), AWS EKS, PostgreSQL (RDS Global Database), Redis (ElastiCache), Istio, Prometheus, Grafana, Loki, and Terraform**.

This document provides:
1. **Application Overview (Detailed Explanation)**
2. **Architecture Overview (Detailed Explanation)**
3. **Infrastructure Setup (Terraform, Helm, Kubernetes)**
4. **Service Mesh Integration (Istio Traffic Control, mTLS, Virtual Services)**
5. **Disaster Recovery (Backup Strategy, Failover, Route 53 Multi-Region Support)**
6. **Security Controls (IAM, WAF, Encryption, Zero-Trust Model)**
7. **Monitoring & Observability Setup (Prometheus, Grafana, Loki)**
8. **Testing & Failover Simulation (Automated Scripts & Load Testing)**
9. **Deployment Guide (Step-by-step commands for setup & monitoring)**

---

## **1. Application Overview**
### **Introduction**
The **Financial Transaction Processing System** is designed to process high volumes of **secure, real-time transactions** with high availability, fault tolerance, and regulatory compliance. It ensures financial data consistency and security while leveraging a **multi-tier architecture** for performance and resilience.

### **Key Features**
- **ACID-Compliant Transactions**: PostgreSQL ensures strict consistency for all financial transactions.
- **Multi-Region Deployment**: Supports **active-active setup** for high availability.
- **RDS Global Database**: PostgreSQL with **cross-region replication** and failover.
- **Istio Service Mesh**: Enables **secure communication and traffic routing**.
- **Redis Caching**: Reduces latency for balance queries.
- **AWS WAF & IAM Security**: Protects against cyber threats.
- **Disaster Recovery (DR) Plan**: Backup automation and multi-region failover.

### **Application Implementation**
#### **Endpoints:**
- **POST /process_transaction**: Processes a new financial transaction.
- **GET /transactions**: Retrieves all transactions.
- **GET /balance/<account_id>**: Fetches account balance with Redis caching.

#### **Data Consistency & Transaction Management:**
- **PostgreSQL RDS (Global Database) ensures strict ACID transactions.**
- **Each transaction is uniquely logged to prevent duplication.**
- **Row-level locking (SELECT FOR UPDATE) prevents race conditions in concurrent transactions.**

#### **Caching Strategy:**
- **Redis is used for caching frequently accessed balance queries.**
- **Cache invalidation ensures real-time data updates.**

#### **Logging & Monitoring:**
- **API requests and transactions are logged using Loki.**
- **Prometheus collects transaction metrics, request latencies, and errors.**

## Technologies Used
- **Python (Flask)** - API framework
- **PostgreSQL** - ACID-compliant database for financial transactions
- **Redis** - Caching frequently accessed data
- **Docker** - Containerization for easy deployment
- **Kubernetes** - Orchestration and scalability
- **GitHub Actions** - CI/CD automation
- **Locust** - Load testing framework

## Architecture Diagram
```
(Client) -> (Flask API) -> (PostgreSQL) -> (Redis for caching)
                 \                 /
              (Kubernetes & Docker)
```

## Installation & Setup
### **1. Clone the Repository**
```sh
git clone https://github.com/your-repo/financial-transaction-system.git
cd financial-transaction-system
```

### **2. Start PostgreSQL & Redis (Docker)**
```sh
docker-compose up -d
```
Ensure PostgreSQL is running on port **5432** and Redis on **6379**.

### **3. Install Dependencies**
```sh
pip install -r requirements.txt
```

### **4. Run Migrations & Start Server**
```sh
python app.py
```
The API runs at `http://127.0.0.1:5000`

## API Endpoints
### **1. Get Account Balance (with caching)**
```sh
GET /balance/<account_id>
```
_Response:_
```json
{
  "account_id": 1,
  "balance": 500.0,
  "cached": false
}
```

### **2. Process a Transaction**
```sh
POST /transaction
```
_Request Body:_
```json
{
  "from": 1,
  "to": 2,
  "amount": 100
}
```
_Response:_
```json
{
  "txn_id": "unique-id",
  "status": "completed"
}
```

### **3. Get Transaction History**
```sh
GET /transactions
```
_Response:_
```json
[
  {
    "id": "txn-uuid",
    "from": 1,
    "to": 2,
    "amount": 100.0,
    "status": "completed"
  }
]
```

## Docker Implementation
### **1. Create a Dockerfile**
```dockerfile
FROM python:3.9
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["python", "app.py"]
```

### **2. Build & Run Docker Container**
```sh
docker build -t transaction-service .
docker run -p 5000:5000 transaction-service
```

### **3. Deploy with Docker Compose**
Create `docker-compose.yml`:
```yaml
version: '3.8'
services:
  app:
    build: .
    ports:
      - "5000:5000"
    depends_on:
      - db
      - redis
  db:
    image: postgres
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
      POSTGRES_DB: transaction_db
    ports:
      - "5432:5432"
  redis:
    image: redis
    ports:
      - "6379:6379"
```

Run the application:
```sh
docker-compose up -d
```

## Kubernetes Deployment
### **1. Create Deployment YAML (`deployment.yaml`)**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: transaction-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: transaction-service
  template:
    metadata:
      labels:
        app: transaction-service
    spec:
      containers:
        - name: transaction-service
          image: myrepo/transaction-service:latest
          ports:
            - containerPort: 5000
          env:
            - name: DATABASE_URL
              value: "postgresql://user:password@postgres-service/transaction_db"
---
apiVersion: v1
kind: Service
metadata:
  name: transaction-service
spec:
  type: LoadBalancer
  ports:
    - port: 80
      targetPort: 5000
  selector:
    app: transaction-service
```

### **2. Deploy to Kubernetes**
```sh
kubectl apply -f deployment.yaml
```

## Load Testing (Concurrency)
### **1. Install Locust**
```sh
pip install locust
```

### **2. Run Load Test**
```sh
locust -f locustfile.py --host=http://127.0.0.1:5000
```
---

## **2. Architecture Overview**
The cloud architecture consists of multiple components working together to ensure high availability, fault tolerance, and scalability.

### **Components & Their Roles:**
1. **VPC with Public & Private Subnets:** Ensures network isolation and secure access.
2. **AWS EKS Cluster:** Orchestrates the microservices and provides auto-scaling.
3. **RDS Global Database:** Ensures data consistency and failover capabilities.
4. **Redis ElastiCache:** Enhances performance with low-latency caching.
5. **Istio Service Mesh:** Manages microservices networking and enforces security policies.
6. **AWS WAF:** Protects against cyber attacks like SQL Injection and DDoS.
7. **AWS Route 53:** Provides DNS-based failover and global load balancing.
8. **AWS CloudFront:** Caches static content and APIs for performance enhancement.
9. **Prometheus, Grafana, Loki:** Provide real-time monitoring and observability.


### **Infrastructure Setup:**

1. **Multi-Region Setup**

    Primary Region: us-east-1 (handles real-time transactions).

    Secondary Region: us-west-2 (acts as a failover region).

2. **VPC Design**

    ***Public Subnet:***

        Hosts the API Gateway for external communication.

    ***Private Subnet:***

        Hosts the EKS cluster, RDS (PostgreSQL), and Redis for secure internal communication.

3. **EKS Cluster**

    ***Primary EKS Cluster (us-east-1):***

        Runs the Flask application.

        Managed by Istio Service Mesh.

    ***Secondary EKS Cluster (us-west-2):***

        Standby cluster for failover.

4. **RDS (PostgreSQL)**

    ***Primary RDS (us-east-1):***

        Handles all write operations.

        Synchronously replicates data to the Secondary RDS in us-west-2.

    ***Secondary RDS (us-west-2):***

        Standby database for failover.

5. **Redis**

    ***Primary Redis (us-east-1):***

        Caching layer for duplicate transaction detection.

    ***Secondary Redis (us-west-2):***

        Replica for high availability.

6. **Istio Service Mesh**

    Gateway: Exposes the Flask application to external traffic.

    Virtual Service: Routes traffic to the Flask application.

    mTLS: Ensures secure communication between services.

    Prometheus + Grafana: Provides monitoring and alerting.

7. **Route 53**

    Health Checks: Monitors the health of the primary region.

    DNS Failover: Automatically routes traffic to the secondary region if the primary fails.

8. **Backups**

    RDS Automated Backups: Daily backups retained for 7 days.

    S3 Bucket: Stores RDS backups.

9. **Lambda Function**

    Promote Secondary RDS: Promotes the secondary RDS to primary during failover.

### Service Mesh Integration

**Istio**

Istio is used as the service mesh to provide:

    Traffic Management:

        Istio Gateway: Exposes the Flask application to external traffic.

        Virtual Service: Routes traffic to the Flask application.

    Security:

        Mutual TLS (mTLS): Ensures secure communication between services.

    Observability:

        Prometheus: Collects metrics from the Flask application.

        Grafana: Provides dashboards for monitoring and alerting.

### Disaster Recovery

**Backup Strategy**

    RDS Automated Backups: Daily backups retained for 7 days.

    S3 Bucket: Stores RDS backups.

**Failover Mechanisms**

    Route 53 Health Checks: Monitors the health of the primary region.

    Lambda Function: Promotes the secondary RDS to primary during failover.

**Testing**

    Simulate RDS Failover: Promotes the secondary RDS to primary.

    Test Route 53 Failover: Simulates a failure in the primary region and verifies DNS failover.

    Test Lambda Function: Tests the Lambda function for promoting the secondary RDS to primary.

### Security
**IAM Roles**

    Least privilege access for services.

**WAF (Web Application Firewall)**

    Protects against SQL injection and DDoS attacks.

**Encryption**

    Data encrypted at rest (AES-256) and in transit (TLS).

**mTLS**

    Ensures secure communication between services in the Istio service mesh.

### Monitoring and Observability
**Prometheus**

    Collects metrics from the Flask application.

**Grafana**

    Provides dashboards for monitoring and alerting.

![alt text](image.png)

### Testing
**Scripts**

    Simulate RDS Failover:

    ```bash
    ./scripts/simulate_rds_failover.sh
    ```

    Test Route 53 Failover:
    ```bash
    ./scripts/test_route53_failover.sh
    ```
    
    Test Lambda Function:
    ```bash
    ./scripts/test_lambda_failover.sh
    ```

    Test Backups:
    ```bash
    ./scripts/test_backups.sh
    ```
    Test Redis Replication:
    ```bash
    ./scripts/test_redis_replication.sh
    ```
    Test Istio Service Mesh:
    ```bash
    ./scripts/test_istio.sh
    ```
---

## **3. Infrastructure Setup (Terraform & Kubernetes)**


### **Step 1: Deploy Infrastructure Using Terraform**
```sh
cd infra/
terraform init
terraform apply -auto-approve
```

### **Step 2: Deploy Application Using Helm**
```sh
cd app/helm
helm install transaction-service .
```

### **Step 3: Configure Istio Service Mesh**
```sh
kubectl apply -f istio-gateway.yaml
kubectl apply -f istio-virtualservice.yaml
```

### **Step 4: Verify Deployment**
```sh
kubectl get pods -n default
kubectl get services -n default
```

---

## **4. Monitoring & Observability**
### **Install Prometheus, Grafana, Loki Stack**
```sh
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install monitoring grafana/loki-stack
```

### **Access Grafana UI**
```sh
kubectl port-forward svc/monitoring-grafana 3000:80
```
- **URL**: http://localhost:3000
- **Default Login**: `admin` / `prom-operator`

---

## **5. Testing API Endpoints**
### **Test Transaction Processing**
```sh
curl -X POST http://localhost:5000/process_transaction -H "Content-Type: application/json" -d '{"from":1, "to":2, "amount":100}'
```

### **Check Account Balance**
```sh
curl -X GET http://localhost:5000/balance/1
```

### **Retrieve All Transactions**
```sh
curl -X GET http://localhost:5000/transactions
```

---

## **6. Failover & Disaster Recovery**
### **Automated Failover Tests**
- **Simulate RDS Failover:**
  ```sh
  bash scripts/simulate_rds_failover.sh
  ```
- **Test Route 53 Failover:**
  ```sh
  bash scripts/test_route53_failover.sh
  ```
- **Test Redis Replication:**
  ```sh
  bash scripts/test_redis_replication.sh
  ```

### **Disaster Recovery Strategy**
- **Daily backups stored in AWS S3.**
- **Automated recovery scripts to restore from backup in case of failure.**

---

## **7. Security Best Practices**
- **IAM Roles & Least Privilege Access:** Ensures only necessary permissions are granted.
- **AWS WAF Protection:** Prevents attacks like SQL injection and cross-site scripting.
- **TLS Encryption:** Ensures secure API communications.
- **VPC Security Groups:** Restrict traffic access to sensitive resources.

---

## **8. Conclusion**
This **Financial Transaction Processing System** is designed with **scalability, security, failover, and high availability** in mind. With **multi-region replication, Istio service mesh, and full observability**, it ensures a **resilient and production-ready solution** for handling real-time payments.



