resource "aws_instance" "website-server" {
  ami                    = "ami-0b0b78dcacbab728f"
  instance_type          = "t3.micro"
  key_name               = "website-key"
  vpc_security_group_ids = [aws_security_group.website-sg.id]

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  depends_on = [
    aws_iam_role_policy_attachment.attach_ecr_policy
  ]

  tags = {
    Name        = "website-server-prd"
    provisioner = "terraform"
  }
}

resource "aws_security_group" "website-sg" {
  name   = "website-sg"
  vpc_id = "vpc-059e9913647482d9d"

  description = "Security group do website server"

  tags = {
    Name = "website-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.website-sg.id
  cidr_ipv4         = "189.79.2.181/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.website-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.website-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


resource "aws_iam_role" "ec2_ecr_role" {
  name = "ec2-ecr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"

        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "ec2-ecr-role"
  }
}


resource "aws_iam_policy" "ecr_pull_policy" {
  name = "ecr-pull-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_ecr_policy" {
  role       = aws_iam_role.ec2_ecr_role.name
  policy_arn = aws_iam_policy.ecr_pull_policy.arn
}


resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-ecr-instance-profile"
  role = aws_iam_role.ec2_ecr_role.name
}