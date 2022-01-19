locals {
  vpc_id         = aws_default_vpc.default_vpc.id
  pri_subnet_ids = [aws_default_subnet.default_subnet_a.id,aws_default_subnet.default_subnet_b.id,aws_default_subnet.default_subnet_c.id]
  pub_subnet_ids = [aws_default_subnet.default_subnet_a.id,aws_default_subnet.default_subnet_b.id,aws_default_subnet.default_subnet_c.id]
}