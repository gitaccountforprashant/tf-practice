
provider "aws" {
  access_key = ""
  secret_key = ""
  region     = "us-west-2"
}


resource "aws_vpc" "main-vpc" {
  cidr_block = "10.0.0.0/16"

  tags {
  Name = "test-vpc"
  }
}

resource "aws_internet_gateway" "main-igw" {
  vpc_id = "${aws_vpc.main-vpc.id}"

  tags {
    Name = "test-igw"
  }
}


resource "aws_subnet" "main-pub-subnet1" {
  vpc_id     = "${aws_vpc.main-vpc.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a"

  tags {
    Name = "test-pub-sn-1"
  }
}


resource "aws_subnet" "main-pub-subnet2" {
  vpc_id     = "${aws_vpc.main-vpc.id}"
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-west-2b"

  tags {
    Name = "test-pub-sn-2"
  }
}


resource "aws_subnet" "main-pvt-subnet1" {
  vpc_id     = "${aws_vpc.main-vpc.id}"
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-2a"

  tags {
    Name = "test-pvt-sn-1"
  }
}


resource "aws_subnet" "main-pvt-subnet2" {
  vpc_id     = "${aws_vpc.main-vpc.id}"
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-west-2b"

  tags {
    Name = "test-pvt-sn-2"
  }
}

resource "aws_route_table" "main-rt-pub" {
  vpc_id = "${aws_vpc.main-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main-igw.id}"
  }

  tags {
    Name = "test-rt-pub"
  }
}

resource "aws_route_table_association" "main-rt-asso1" {
  subnet_id      = "${aws_subnet.main-pub-subnet1.id}"
  route_table_id = "${aws_route_table.main-rt-pub.id}"
}
resource "aws_route_table_association" "main-rt-asso2" {
  subnet_id      = "${aws_subnet.main-pub-subnet2.id}"
  route_table_id = "${aws_route_table.main-rt-pub.id}"
}



resource "aws_instance" "main-natin" {
  ami           = "ami-0b707a72"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.main-pub-subnet1.id}"
  source_dest_check = "False"
  # value of key_name can b both as below
# key_name = "test-keypair"
  key_name = "${aws_key_pair.main-keypair.key_name}"
  vpc_security_group_ids = ["${aws_security_group.main-sg-natin.id}"]



  tags {
    Name = "test-Natinstancce"
  }
}


resource "aws_key_pair" "main-keypair" {
  key_name   = "test-keypair"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDNfHpm/xSlCy4nYdSOJFEiHzPaXAM/hs6vJMrigH3BmpWlcboCRBLRfSj6z/3E7aXmD+BDpyCKjbZSKEi8PbnYHD9uVql2w9kiRkP0nvD8Tu1hNF/X8RDHHdiVkVanDt2zH/3fFLOPlT0aW5dsOgE/xM7eZpS90mbLXlKe+k5fLx/8Dd+1K+MqgjnQhplmcJrXekGZ0ZXOghUdFFwZZgohCymgikcpzdX8O+53BTGvNks6Pg9J6kRFXTBCoZ14imjUezaVK3VYN5tD/ov4SPKSLE8gxBd1x6QH6EtBOkLgeuoCX03tqeymPMtPo79sTTsqL6/c5exddGRlZ4hojjS5 prashantsharma@GGN-157952-C02TK1RNGTFM"
}

resource "aws_eip" "main-eip" {
  instance = "${aws_instance.main-natin.id}"
  vpc      = true
}


resource "aws_security_group" "main-sg-natin" {
  name        = "allow_from_test_pvtsn"
  vpc_id = "${aws_vpc.main-vpc.id}"


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.2.0/24","10.0.3.0/24"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.2.0/24","10.0.3.0/24"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags {
  Name = "test-sg-nat"
}
}

resource "aws_route_table" "main-rt-pvt" {
  vpc_id = "${aws_vpc.main-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    instance_id = "${aws_instance.main-natin.id}"
  }

  tags {
    Name = "test-rt-pvt"
  }
}

resource "aws_route_table_association" "main-rt-asso3" {
  subnet_id      = "${aws_subnet.main-pvt-subnet1.id}"
  route_table_id = "${aws_route_table.main-rt-pvt.id}"
}
resource "aws_route_table_association" "main-rt-asso4" {
  subnet_id      = "${aws_subnet.main-pvt-subnet2.id}"
  route_table_id = "${aws_route_table.main-rt-pvt.id}"
}
