resource "aws_instance" "db" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "m4.large"

  key_name = aws_key_pair.admin.key_name
  security_groups = [aws_security_group.db.name]

  tags = {
    Name = "db"
  }
}

resource "aws_security_group" "db" {
  name = "foodb"

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # PostgreSQL in
  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP in
  ingress {
    from_port   = 0
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS out
  egress {
    from_port   = 0
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}