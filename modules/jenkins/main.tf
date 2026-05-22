resource "aws_instance" "jenkins_master" {
  ami           = "ami-0f58b397bc5c1f2e8"
  instance_type = "t3.medium"

  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.jenkins_sg_id]

  associate_public_ip_address = true

  tags = {
    Name = "jenkins-master"
  }
}

resource "aws_instance" "jenkins_agent" {
  ami           = "ami-0f58b397bc5c1f2e8"
  instance_type = "t3.medium"

  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [var.jenkins_sg_id]

  tags = {
    Name = "jenkins-agent"
  }
}