locals {
  resource_name = var.resource_name
  instance_type = "t2.micro"
  http_port     = var.http_port
  postgre_port  = var.postgre_port
}

module "Networking" {
  source                = "../modules/Networking"
  vpc_cidr_block        = ""
  resource_name         = local.resource_name
  public_subnet_count   = 2
  private_subnet_count  = 2
  ssh_port              = 22
  http_port             = local.http_port
  postgre_port          = local.postgre_port  
}

module "Compute" {
  source        = "../modules/Compute"
  resource_name = local.resource_name
  instance_type = local.instance_type
  asg_sg_id     = module.Networking.two_tier_asg_sg_id
  elb_tg_arn    = module.LoadBalancing.elb_tg_arn
  public_subnet = module.Networking.public_subnet_ids
}

module "LoadBalancing" {
  source        = "../modules/LoadBalancing"
  resource_name = local.resource_name
  elb_sg_id     = module.Networking.elb_sg_id
  vpc_id        = module.Networking.vpc_id
  public_subnet = module.Networking.public_subnet_ids
  http_port     = local.http_port
  protocol      = "HTTP"
}

module "Database" {
  source                = "../modules/database"
  resource_name         = local.resource_name
  db_allocated_storage  = 20
  engine                = "postgres"
  engine_version        = "16.4"
  db_instance_class     = "db.t2.micro"
  db_port               = 5432
  db_subnet_group_name  = module.Networking.rds_subnet_group_name
  username              = var.rds_username
  password              = var.rds_password
}