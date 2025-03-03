output "primary_db_endpoint" {
  value = aws_route53_record.primary_db.name
}

output "secondary_db_endpoint" {
  value = aws_route53_record.secondary_db.name
}