provider "aws" {
  region = var.aws_region
}

############################
# SECURITY GROUP
############################
resource "aws_security_group" "sg" {
  name   = "${var.project_name}-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

############################
# IAM ROLE
############################
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

############################
# SSM PARAMETER
############################
resource "aws_ssm_parameter" "my_secret" {
  name  = "/${var.project_name}/${var.environment}/MY_SECRET_NUMBER"
  type  = "SecureString"
  value = var.MY_SECRET_NUMBER
}

############################
# IAM POLICY
############################
resource "aws_iam_policy" "ssm_policy" {
  name = "${var.project_name}-ssm-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["ssm:GetParameter"]
      Resource = aws_ssm_parameter.my_secret.arn
    }]
  })
}

############################
# ATTACH POLICY TO ROLE
############################
resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ssm_policy.arn
}

resource "aws_iam_role_policy_attachment" "ssm_managed_core" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

############################
# INSTANCE PROFILE
############################
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-instance-profile"
  role = aws_iam_role.ec2_role.name
}

############################
# EC2 INSTANCE
############################
resource "aws_instance" "node_app" {
  ami           = "ami-0c42696027a8ede58" # Amazon Linux 2 (us-east-1)
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = var.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.sg.id]
  iam_instance_profile  = aws_iam_instance_profile.ec2_profile.name

 user_data = <<EOF
#!/bin/bash
yum update -y

cd /tmp
yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

yum install -y aws-cli
yum install -y docker
systemctl start docker
systemctl enable docker

aws ssm get-parameter \
  --name "/${var.project_name}/${var.environment}/MY_SECRET_NUMBER" \
  --with-decryption \
  --region ${var.aws_region} \
  --query "Parameter.Value" \
  --output text > /tmp/secret

docker run \
  --name my-app \
  -e MY_SECRET_NUMBER="$(cat /tmp/secret)" \
  -p 3000:3000 \
  shefeekar/myapp:latest
  EOF
   tags = {
    Name = "${var.project_name}-nodejs-app"
  }
}
