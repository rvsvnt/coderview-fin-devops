output "rds_endpoint" {
  value = module.rds_primary.rds_endpoint
}

output "redis_endpoint" {
  value = module.redis_primary.redis_endpoint
}

output "eks_cluster_name" {
  value = module.eks_primary.eks_cluster_name
}