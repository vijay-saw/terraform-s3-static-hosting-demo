
resource "aws_vpc" "myvpc" {
    cidr_block = var.vpcidr
  tags = {
    Name="vijayvpc"
  }
}

#subnet for instance static web hosting
resource "aws_subnet" "mysubnet" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = var.subnetcidr
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
  
}
#subnet for instnce nginx server

resource "aws_subnet" "mysubnet2" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = var.subnet2cidr
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = true
  
}

resource "aws_internet_gateway" "myig" {
    vpc_id = aws_vpc.myvpc.id
    tags = {
      Name="myigw"
    }

  
}
resource "aws_route_table" "myroute" {
    vpc_id = aws_vpc.myvpc.id

    route  {
        cidr_block="0.0.0.0/0"
        gateway_id=aws_internet_gateway.myig.id
    }
  
}

resource "aws_route_table_association" "myassn" { 
    subnet_id=aws_subnet.mysubnet.id
    route_table_id = aws_route_table.myroute.id

  
}

resource "aws_route_table_association" "forsubnet2" {
    subnet_id = aws_subnet.mysubnet2.id
    route_table_id = aws_route_table.myroute.id
  
}


resource "aws_security_group" "mysecurity" {

    vpc_id = aws_vpc.myvpc.id
    name = "web"
    ingress  {
        protocol = "tcp"
        from_port=80
        to_port=80
        cidr_blocks = ["0.0.0.0/0"]
        
    }

     ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
  tags = {
    Name="mysg"
  }
  
}
#ec2 instance for static web hosting
resource "aws_instance" "terraforminstance" {
  instance_type          = var.instancetype
  ami                    = var.awsami
#   key_name               = aws_key_pair.mykey.key_name  # Uncomment if using a key pair
  tags = {
    Name = "terraforminstance"
  }
  vpc_security_group_ids = [aws_security_group.mysecurity.id]  
  subnet_id              = aws_subnet.mysubnet.id
  availability_zone      = "us-east-1a"  

 
}


#ec2 instance for nginx server

resource "aws_instance" "nginxserver" {
  instance_type          = "t2.micro"
  ami                    = var.nginxserverami # Ensure this is set to an Amazon Linux AMI ID
  tags = {
    Name = "nginxserver"
  }
  vpc_security_group_ids = [aws_security_group.mysecurity.id]
  subnet_id              = aws_subnet.mysubnet2.id
  # availability_zone      = "us-east-1"
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y nginx
              systemctl start nginx
              systemctl enable nginx
              echo "Hello from Nginx in Subnet A" > /usr/share/nginx/html/index.html
              EOF
}



resource "aws_s3_bucket" "vijaybucket" {

    bucket = var.bucketname

}

resource "aws_s3_bucket_ownership_controls" "vijayowner" {

    bucket = aws_s3_bucket.vijaybucket.id
    rule {
      object_ownership = "BucketOwnerPreferred"
    }
  
}

resource "aws_s3_bucket_public_access_block" "publicacces" {
  bucket = aws_s3_bucket.vijaybucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
resource "aws_s3_bucket_acl" "myacl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.vijayowner,
    aws_s3_bucket_public_access_block.publicacces,
  ]

  bucket = aws_s3_bucket.vijaybucket.id
  acl    = "public-read"
}

resource "aws_s3_object" "index" {

    bucket = aws_s3_bucket.vijaybucket.id
    key="index.html"
    source = "index.html"
    acl = "public-read"
    content_type = "text/html"
  
}


resource "aws_s3_object" "error" {
bucket =aws_s3_bucket.vijaybucket.id
key="error.html"
source="error.html"
acl="public-read"
content_type= "text/html"  
}


resource "aws_s3_object" "profile" {
bucket =aws_s3_bucket.vijaybucket.id
key="profile.jpg"
source="profile.jpg"
acl="public-read" 
}

# aws_s3_bucket_website_configuration

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.vijaybucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

#   routing_rule {
#     condition {
#       key_prefix_equals = "docs/"
#     }
#     redirect {
#       replace_key_prefix_with = "documents/"
#     }
#   }
depends_on = [ aws_s3_bucket_acl.myacl ]

}



#load balancer for staticserver
# Load Balancer Definition
# Load Balancer Definition
# Load Balancer Definition
# Load Balancer Definition
resource "aws_lb" "my_lb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.mysecurity.id]
  subnets            = [aws_subnet.mysubnet.id,aws_subnet.mysubnet2.id]
  enable_deletion_protection = false

  tags = {
    Name = "my-alb"
  }
}

# Target Group for Static Content
resource "aws_lb_target_group" "statictarget" {
  name     = "static-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id
}

# Target Group for Nginx Server
resource "aws_lb_target_group" "nginxtarget" {
  name     = "nginx-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id
}

# Attach EC2 Instances to Target Groups
resource "aws_lb_target_group_attachment" "static_attachment" {
  target_group_arn = aws_lb_target_group.statictarget.arn
  target_id        = aws_instance.terraforminstance.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "nginx_attachment" {
  target_group_arn = aws_lb_target_group.nginxtarget.arn
  target_id        = aws_instance.nginxserver.id
  port             = 80
}

# Creating Listener for ALB with Weighted Routing
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.my_lb.arn
  port              = 80
  protocol          = "HTTP"

  # Default action
  default_action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.statictarget.arn
        weight = 60
      }
      target_group {
        arn    = aws_lb_target_group.nginxtarget.arn
        weight = 40
      }
    }
  }
}

