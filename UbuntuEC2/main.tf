data "aws_ami" "ubuntu" {
  most_recent = true


  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical which publishes Ubuntu
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  tags = {
    Name = "UbuntuInstance"
  }
}

#Network configs

resource "aws_vpc" "my_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "tf-EC2-Ubuntu"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "172.26.15.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "tf-EC2-Ubuntu"
  }
}

resource "aws_network_interface" "foo" {
  subnet_id   = aws_subnet.my_subnet.id
  private_ips = ["172.16.10.100"]

  tags = {
    Name = "primary_network_interface"
  }
}

#Ubuntu Server 20.04 LTS (HVM), SSD Volume Type - ami-0a8e758f5e873d1c1 (64-bit x86) / ami-09e0d6fdf60750e33 (64-bit Arm)

resource "aws_instance" "foo" {
  ami           = "ami-09e0d6fdf60750e33" # eu-west-1
  instance_type = "t2.micro"

  network_interface {
    network_interface_id = aws_network_interface.foo.id
    device_index         = 0
  }

  credit_specification {
    cpu_credits = "unlimited"
  }
}
