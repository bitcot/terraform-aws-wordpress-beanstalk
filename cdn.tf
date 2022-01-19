
# resource "aws_s3_bucket" "bucket" {
#   count  = length(var.environment)
#   bucket = "${var.stack}-${var.environment[count.index]}-media-bucket"

#   tags = {
#     Name = "${var.stack}-${var.environment[count.index]}-bucket"
#   }
#   server_side_encryption_configuration {
#     rule {
#       apply_server_side_encryption_by_default {
#         sse_algorithm     = "AES256"
#       }
#     }
#   }
#   versioning {
#     enabled = true
#   }
# }
# locals {
#   s3_origin_id = "myS3Origin"
# }

# resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
#   count   = length(var.environment)
#   comment = aws_s3_bucket.bucket[count.index].id
# }

# # cloudfront
# resource "aws_cloudfront_distribution" "cdn" {
#   count = length(var.environment)
#   origin {
#     domain_name = aws_s3_bucket.bucket[count.index].bucket_regional_domain_name
#     origin_id   = local.s3_origin_id

#     s3_origin_config {
#       origin_access_identity = "origin-access-identity/cloudfront/${aws_cloudfront_origin_access_identity.origin_access_identity[count.index].id}"
#     }
#   }
#   enabled             = true
#   is_ipv6_enabled     = true
#   comment             = "cdn"
#   default_root_object = "index.html"
#   default_cache_behavior {
#     allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
#     cached_methods   = ["GET", "HEAD"]
#     target_origin_id = local.s3_origin_id
#     forwarded_values {
#       query_string = false
#       cookies {
#         forward = "none"
#       }
#     }
#     viewer_protocol_policy = "redirect-to-https"
#     min_ttl                = 0
#     default_ttl            = 3600
#     max_ttl                = 86400
#   }
#   custom_error_response {
#     error_code = 403
#     response_code = 200
#     response_page_path = "/index.html"
#   }
#   custom_error_response {
#     error_code = 404
#     response_code = 200
#     response_page_path = "/index.html"
#   }
#   restrictions {
#     geo_restriction {
#       restriction_type = "none"
#     }
#   }
#   viewer_certificate {
#     acm_certificate_arn            = var.cdn_cert_arn 
#     cloudfront_default_certificate = var.cdn_cert_arn == null ? true : false
#     ssl_support_method             = var.cdn_cert_arn == null ? null : "sni-only"
#     minimum_protocol_version       = var.cdn_cert_arn == null ? "TLSv1" : var.minimum_client_tls_protocol_version
#   }
#   aliases = var.cdn_cert_arn == null ? null : ["${var.domain_name_cloudfront}"]
#   tags = {
#     Environment = "${var.stack}-${var.environment[count.index]}"
#   }

# }

# resource "aws_s3_bucket_policy" "bucket_policy" {
#   count  = length(var.environment)
#   bucket = aws_s3_bucket.bucket[count.index].id
#   policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": "s3:GetObject",
#       "Principal": {
#         "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.origin_access_identity[count.index].id}"
#       },
#       "Resource": "${aws_s3_bucket.bucket[count.index].arn}/*"
#     }
#   ]
# }
# POLICY
# }
