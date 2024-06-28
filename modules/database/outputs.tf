output "rds_postgres_port" {
  value = aws_db_instance.two_tier_rds_postgre.port
}
output "rds_postgres_endpoint" {
  value = aws_db_instance.two_tier_rds_postgre.endpoint
}
output "rds_db_master_username" {
  value = aws_db_instance.two_tier_rds_postgre.master_user_secret
}
output "rds_db_master_password" {
  value = aws_db_instance.two_tier_rds_postgre.master_password
}
output "rds_db_name" {
  value = aws_db_instance.two_tier_rds_postgre.db_name
}