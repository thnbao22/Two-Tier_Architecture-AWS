resource "aws_db_instance" "two_tier_rds_postgre" {
  db_name                       = "${var.resource_name}-db"
  identifier                    = "${var.resource_name}-rds-postgres"
  allocated_storage             = var.db_allocated_storage
  engine                        = var.engine
  engine_version                = var.engine_version
  instance_class                = var.db_instance_class
  db_subnet_group_name          = var.db_subnet_group_name
  port                          = var.db_port
  multi_az                      = true
  skip_final_snapshot           = true
  username                      = "${var.username}-db-rds"
  password                      = "@-${var.password}-@" 
}