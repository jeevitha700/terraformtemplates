resource "aws_instance" "demo_vm"{
 ami                     = var.ami
 instance_type           = var.type
 user_data               = templatefile("script.tftpl", {
       host_port         = 8080,
       container_port    =80,
         })
 key_name                = "terraformtem"


 provisioner "file" {
   source      = "script.tftpl"
   destination = "/tmp/script.tftpl"

 connection {
  type = "ssh"
  # ...
  script_path = "terraform_provisioner_%RAND%.sh"
   host     = "${var.host}"
   }
} 
provisioner "remote-exec" {


    inline = [
     "chmod +x /tmp/script.tftpl",
     "sudo /tmp/script.tftpl"
   ]
 }


 tags = {
   name  = "Demo VM"
   type  = "Templated"
 }
}
 resource "aws_default_subnet" "default_az1" {
  availability_zone = "ap-south-1a"

  tags = {
    Name = "Default subnet for ap-south-1a"
  }
}

resource "aws_vpc" "vpc1" {
    cidr_block = "10.1.0.0/16"
    tags = {
      Name = "vpc1"
    }

}
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc1.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_internet_gateway" "rtp03-igw" {
    vpc_id = "${aws_vpc.vpc1.id}"
    tags = {
      Name = "rtp03-igw"
    }
}
// Create a route table
resource "aws_route_table" "rtp03-public-rt" {
    vpc_id = "${aws_vpc.vpc1.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.rtp03-igw.id}"
    }
    tags = {
      Name = "rtp03-public-rt"
    }
}



