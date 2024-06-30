variable "resource_name" {
  description   = "The name of the resource"
  type          = string
  default       = "two-tier"
}
variable "http_port" {
  description   = "The port for HTTP"
  type          = number
  default       = 80
}
variable "postgre_port" {
  description   = "The port of RDS PostgreSQL"
  type          = number
  default       = 5432
}
variable "rds_username" {
  description   = "The username for RDS PostgreSQL"
  type          = string
  sensitive     = true
}
variable "rds_password" {
  description   = "The password for RDS PostgreSQL"
  type          = string
  sensitive     = true
}