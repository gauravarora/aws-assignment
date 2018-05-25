resource "aws_vpc" "vpc" {
    cidr_block              = "10.0.0.0/16"
    enable_dns_hostnames    = true
    tags {
        Name = "aws-assignment"
    }
}

resource "aws_subnet" "private_1a" {
    vpc_id              = "${aws_vpc.vpc.id}"
    availability_zone   = "ap-southeast-1a"
    cidr_block          = "10.0.1.0/24"
    tags {
        Name = "aws-assignment-private-1a"
    }
}

resource "aws_subnet" "private_1b" {
    vpc_id              = "${aws_vpc.vpc.id}"
    availability_zone   = "ap-southeast-1b"
    cidr_block          = "10.0.2.0/24"
    tags {
        Name = "aws-assignment-private-1b"
    }
}

resource "aws_subnet" "public_1a" {
    vpc_id              = "${aws_vpc.vpc.id}"
    availability_zone   = "ap-southeast-1a"
    cidr_block          = "10.0.100.0/24"
    tags {
        Name = "aws-assignment-public-1a"
    }
}

resource "aws_subnet" "public_1b" {
    vpc_id              = "${aws_vpc.vpc.id}"
    availability_zone   = "ap-southeast-1b"
    cidr_block          = "10.0.101.0/24"
    tags {
        Name = "aws-assignment-public-1b"
    }
}

resource "aws_eip" "nat" {
    vpc = true
}

resource "aws_internet_gateway" "default" {
    vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_route_table" "default" {
    vpc_id = "${aws_vpc.vpc.id}"
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.default.id}"
    }

    tags {
        Name = "public access"
    }
}

resource "aws_route_table_association" "public_1a" {
    subnet_id       = "${aws_subnet.public_1a.id}"
    route_table_id  = "${aws_route_table.default.id}"
}

resource "aws_route_table_association" "public_1b" {
    subnet_id       = "${aws_subnet.public_1b.id}"
    route_table_id  = "${aws_route_table.default.id}"
 }
