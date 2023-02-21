## Amazon linux2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

#---------------------------------------------------------------
#  인스턴스 생성 3master, 3storage, 2worker
#---------------------------------------------------------------

## 3 master instance
resource "aws_instance" "master" {
  count = length(module.vpc.private_subnets)

  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.small"
  subnet_id     = module.vpc.private_subnets[count.index]

  tags = {
    Name = "master-${count.index}"
  }
}

## 3 storage instance
resource "aws_instance" "storage" {
  count = length(module.vpc.private_subnets)

  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.small"
  subnet_id     = module.vpc.private_subnets[count.index]

  tags = {
    Name = "storage-${count.index}"
  }
}

## 2 worker instance
resource "aws_instance" "worker1" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.medium"
  subnet_id     = module.vpc.private_subnets[0]

  tags = {
    Name = "worker-0"
  }
}
resource "aws_instance" "worker2" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.medium"
  subnet_id     = module.vpc.private_subnets[1]

  tags = {
    Name = "worker-1"
  }
}