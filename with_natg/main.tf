
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



resource "aws_nat_gateway" "main-nat-gw" {
  allocation_id = "${aws_eip.main-eip.id}"
  subnet_id     = "${aws_subnet.main-pub-subnet1.id}"

}


resource "aws_eip" "main-eip" {
  vpc      = true
}


resource "aws_route_table" "main-rt-pvt" {
  vpc_id = "${aws_vpc.main-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.main-nat-gw.id}"
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
