## Amazon linux2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  owners = ["amazon"]
}

#---------------------------------------------------------------
#  앤서블용 인스턴스 및 보안그룹 생성
#---------------------------------------------------------------

## ansible controller Instance 
data "aws_key_pair" "ansible" {
  key_name = "saltware"
}

resource "aws_instance" "ansible-controller" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.small"
  subnet_id     = module.vpc.public_subnets[0]
  key_name      = data.aws_key_pair.ansible.key_name

  tags = {
    Name = "ansible-controller"
  }
}

resource "aws_security_group" "kubernetes" {
  name_prefix = "kubernetes-"
  description = "Security group for Kubernetes cluster"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 10250
    to_port     = 10255
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "kubernetes_egress" {
  security_group_id = aws_security_group.kubernetes.id

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}


#---------------------------------------------------------------
#  인스턴스 생성 3master, 3storage, 2worker
#---------------------------------------------------------------

## 3 master instance
resource "aws_instance" "master" {
  count = length(module.vpc.private_subnets)

  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t3.small"
  subnet_id              = module.vpc.private_subnets[count.index]
  vpc_security_group_ids = [aws_security_group.kubernetes.id]
  key_name               = data.aws_key_pair.ansible.key_name

  tags = {
    Name = "master-${count.index}"
  }
}

# ## 3 storage instance
# resource "aws_instance" "storage" {
#   count = length(module.vpc.private_subnets)

#   ami           = data.aws_ami.amazon_linux_2.id
#   instance_type = "t3.small"
#   subnet_id     = module.vpc.private_subnets[count.index]
#   vpc_security_group_ids = [aws_security_group.kubernetes.id]

#   tags = {
#     Name = "storage-${count.index}"
#   }
# }

## 2 worker instance
resource "aws_instance" "worker1" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t3.medium"
  subnet_id              = module.vpc.private_subnets[0]
  vpc_security_group_ids = [aws_security_group.kubernetes.id]
  key_name               = data.aws_key_pair.ansible.key_name

  tags = {
    Name = "worker-0"
  }
}
resource "aws_instance" "worker2" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t3.medium"
  subnet_id              = module.vpc.private_subnets[1]
  vpc_security_group_ids = [aws_security_group.kubernetes.id]
  key_name               = data.aws_key_pair.ansible.key_name

  tags = {
    Name = "worker-1"
  }
}