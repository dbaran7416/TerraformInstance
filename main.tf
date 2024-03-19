provider "aws" {
    region = "us-east-1"
}

resource "aws_security_group" "Allow-HTTP" {
    name = "Allow-HTTP"
    ingress {
        description = "http"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "ssh"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "All Traffic"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        description = "All Traffic"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "amazon_linux2_virtual_machine" {
    count = 1
    ami = "ami-07761f3ae34c4478d"
    instance_type = "t2.micro"
    key_name = "GenPair"
    tags = {
        Name = "Amazon-Linux-Server"
    }
    user_data = <<-EOF
        #!/bin/bash
        sudo yum update -y
        sudo yum install httpd firewalld -y
        sudo systemctl start httpd
        sudo systemctl enable httpd
        sudo systemctl start firewalld 
        sudo systemctl enable firewalld
        sudo firewall-cmd --permanent --add-service=http
        sudo firewall-cmd --reload
        echo "This is for hostname $(hostname -f)" >> /var/www/html/index.html
    EOF

    vpc_security_group_ids = [aws_security_group.Allow-HTTP.id] 
}

