resource "aws_db_instance" "rds_backup" {
  identifier          = "rds-backup"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  engine              = "postgres"
  username            = "user"
  password            = "password"
  publicly_accessible = false
  backup_retention_period = 7
  backup_window       = "03:00-04:00"
  skip_final_snapshot = true
}

resource "aws_s3_bucket" "backup_bucket" {
  bucket = "rds-backup-bucket"
  acl    = "private"
}

resource "aws_s3_bucket_policy" "backup_bucket_policy" {
  bucket = aws_s3_bucket.backup_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.backup_bucket.arn}/*"
      }
    ]
  })
}