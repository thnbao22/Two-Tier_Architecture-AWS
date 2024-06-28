resource "aws_vpc" "two_tier_vpc" {
  cidr_block            = "${var.vpc_cidr_block}"
  enable_dns_support    = true
  enable_dns_hostnames  = true
  tags = {
    Name = "${var.resource_name}-vpc"
  } 
}

resource "aws_internet_gateway" "two_tier_igw" {
  vpc_id = "${aws_vpc.two_tier_vpc.id}"
  tags = {
    "Name" = "${var.resource_name}-internet-gateway"
  }
}

data "aws_availability_zones" "available" {
  
}
# Two Public Subnets
resource "aws_subnet" "two_tier_public_subnet" {
  vpc_id                    = "${aws_vpc.two_tier_vpc.id}"
  count                     = "${var.public_subnet_count}"
  cidr_block                = "10.10.${count.index + 1}.0/24"
  availability_zone         = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch   = true    
  tags = {
    "Name" = "${var.resource_name}-public-subnet-${count.index + 1}"
  }
}
# Two Private Subnets
resource "aws_subnet" "two_tier_private_subnet" {
  vpc_id                    = "${aws_vpc.two_tier_vpc.id}"
  count                     = "${var.private_subnet_count}"
  cidr_block                = "10.10.${count.index + 3}.0/24"
  availability_zone         = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch   = false
  tags = {
    "Name" = "${var.resource_name}-private-subnet-${count.index + 1}"
  }
}
# Route Table for Public Subnets
resource "aws_route_table" "two_tier_rt" {
  vpc_id = "${aws_vpc.two_tier_vpc.id}"    
  tags = {
    "Name" = "${var.resource_name}-route-table"
  }
}

resource "aws_route" "two_tier_public_subnet_rt" {
  route_table_id            = "${aws_route_table.two_tier_rt.id}"
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = "${aws_internet_gateway.two_tier_igw.id}"
}

resource "aws_route_table_association" "two_tier_public_subnet_rt_association" {
  route_table_id    = "${aws_route_table.two_tier_rt.id}"
  count             = "${var.public_subnet_count}"
  subnet_id         = "${aws_subnet.two_tier_public_subnet.*.id}" 
}

# Security Group for ELB
resource "aws_security_group" "two_tier_elb_sg" {
  vpc_id        = "${aws_vpc.two_tier_vpc.id}" 
  description   = "Allow inbound traffic form the internet on HTTP port" 
  name          = "${var.resource_name}-elb-sg"
  ingress {
    from_port   = "${var.http_port}"
    to_port     = "${var.http_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Retrieve the local IP address of your local machine
data "http" "local_ip" {
  url = "https://ipv4.icanhazip.com"
}

# Security Group for ASG
resource "aws_security_group" "two_tier_asg_sg" {
  vpc_id        = "${aws_vpc.two_tier_vpc.id}"
  name          = "${var.resource_name}-asg-sg"
  description   = "Allow inbound traffic from ELB on http port and SSH from the local IP address"
  ingress {
    from_port       = "${var.http_port}"
    to_port         = "${var.http_port}"
    protocol        = "tcp"
    security_groups = ["${aws_security_group.two_tier_elb_sg.id}"]
  }
  ingress {
    from_port       = "${var.ssh_port}"
    to_port         = "${var.ssh_port}"
    protocol        = "tcp"
    cidr_blocks     = ["${chomp(data.http.local_ip.response_body)}/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for RDS
resource "aws_security_group" "two_tier_rds_sg" {
  vpc_id        = "${aws_vpc.two_tier_vpc.id}"
  name          = "${var.resource_name}-rds-sg"
  description   = "Allow inbound traffic from ASG on PostgreSQL port"
  ingress {
    from_port       = "${var.postgre_port}"
    to_port         = "${var.postgre_port}"
    protocol        = "tcp"
    security_groups = ["${aws_security_group.two_tier_asg_sg.id}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  count       = "${var.private_subnet_count}"
  name        = "${var.resource_name}-rds-subnet-group"
  subnet_ids  = ["${aws_subnet.two_tier_private_subnet[0].id}", "${aws_subnet.two_tier_private_subnet[2].id}"]
  tags = {
    "Name" = "SubnetGroupRDS"
  }
}