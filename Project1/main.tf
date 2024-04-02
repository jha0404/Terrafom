data "aws_ami" "amazon" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}
output "test" {
  value = data.aws_ami.amazon.id
}

resource  "aws_instance" "ec2" {
    ami =  data.aws_ami.amazon.id
    instance_type = "t2.micro"

}

output "public_ip" {
    value = aws_instance.ec2.public_ip
}
