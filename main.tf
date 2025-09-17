resource "aws_vpc" "tervpc" {
    cidr_block   = var.cidr
}
resource "aws_subnet" "sub1" {
    vpc_id = aws_vpc.tervpc.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "ap-south-1a"
     map_public_ip_on_launch = true

}
resource "aws_subnet" "sub2" { 
    vpc_id = aws_vpc.tervpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-south-1b"
    map_public_ip_on_launch = true
}
resource "aws_internet_gateway" "igw" {
    vpc_id =aws_vpc.tervpc.id
}
resource "aws_route_table" "rt" {
    vpc_id =aws_vpc.tervpc.id
    route {
        cidr_block ="0.0.0.0/0"
        gateway_id =aws_internet_gateway.igw.id
    }

}
#route table association
resource "aws_route_table_association" "a1"{
    subnet_id =aws_subnet.sub1.id
    route_table_id =aws_route_table.rt.id
}
resource "aws_route_table_association" "a2"{
    subnet_id =aws_subnet.sub2.id
    route_table_id =aws_route_table.rt.id
}
resource "aws_security_group" "sg1"{
   name_prefix= "web-sg"
   description= "web server"
   vpc_id=aws_vpc.tervpc.id 
      ingress{
        description="HTTP"
        from_port=80
        to_port=80
        protocol="tcp"
        cidr_blocks=["0.0.0.0/0"]
      } 
      ingress{
        description="ssh"
        from_port=22
        to_port=22
        protocol="tcp"
        cidr_blocks=["0.0.0.0/0"]
      } 
      egress{
        from_port=0
        to_port=0
        protocol="-1"
        cidr_blocks=["0.0.0.0/0"]
      }

      tags = {
        Name="web-sg"
      }
     
}

resource "aws_s3_bucket" "exam"{
    bucket="maheswariterraformproject"

}
resource "aws_instance" "web-server1"{
    ami = "ami-0b982602dbb32c5bd" # Ubuntu 22.04 LTS (ap-south-1)
    instance_type="t3.micro"
    vpc_security_group_ids=[aws_security_group.sg1.id]
    subnet_id=aws_subnet.sub1.id
    associate_public_ip_address = true
    user_data=file("userdata.sh")

}
resource "aws_instance" "web-server2"{
    ami="ami-0b982602dbb32c5bd" # Ubuntu 22.04 LTS (ap-south-1)

    instance_type="t3.micro"
    vpc_security_group_ids=[aws_security_group.sg1.id]
    subnet_id=aws_subnet.sub2.id
    associate_public_ip_address = true
    user_data=file("userdata1.sh")
    
}
# resource "aws_lb" "myalb" {
#   name               = "myalb"
#   internal           = false
#   load_balancer_type = "application"

#   security_groups = [aws_security_group.webSg.id]
#   subnets         = [aws_subnet.sub1.id, aws_subnet.sub2.id]

#   tags = {
#     Name = "web"
#   }
# }

# resource "aws_lb_target_group" "tg" {
#   name     = "myTG"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = aws_vpc.myvpc.id

#   health_check {
#     path = "/"
#     port = "traffic-port"
#   }
# }
# resource "aws_lb_target_group_attachment" "attach1" {
#   target_group_arn = aws_lb_target_group.tg.arn
#   target_id        = aws_instance.webserver1.id
#   port             = 80
# }

# resource "aws_lb_target_group_attachment" "attach2" {
#   target_group_arn = aws_lb_target_group.tg.arn
#   target_id        = aws_instance.webserver2.id
#   port             = 80
# }

# resource "aws_lb_listener" "listener" {
#   load_balancer_arn = aws_lb.myalb.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     target_group_arn = aws_lb_target_group.tg.arn
#     type             = "forward"
#   }
# }

# output "loadbalancerdns" {
#   value = aws_lb.myalb.dns_name
# }

