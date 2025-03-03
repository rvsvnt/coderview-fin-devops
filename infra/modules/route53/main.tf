resource "aws_route53_zone" "primary" {
  name = "example.com"
}

resource "aws_route53_record" "primary_db" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "db.example.com"
  type    = "CNAME"
  ttl     = 300
  records = [var.primary_rds_endpoint]
}

resource "aws_route53_health_check" "primary_health_check" {
  ip_address        = var.primary_rds_endpoint
  port              = 5432
  type              = "TCP"
  failure_threshold = 3
}

resource "aws_route53_record" "secondary_db" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "db-secondary.example.com"
  type    = "CNAME"
  ttl     = 300
  records = [var.secondary_rds_endpoint]
}

resource "aws_route53_health_check" "secondary_health_check" {
  ip_address        = var.secondary_rds_endpoint
  port              = 5432
  type              = "TCP"
  failure_threshold = 3
}