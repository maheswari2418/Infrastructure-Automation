# =====================================================
# OUTPUTS
# =====================================================

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "web_servers" {
  description = "Web server details"
  value = {
    web_server_1 = {
      id        = aws_instance.web_1.id
      public_ip = aws_instance.web_1.public_ip
    }
    web_server_2 = {
      id        = aws_instance.web_2.id
      public_ip = aws_instance.web_2.public_ip
    }
  }
}

output "app_servers" {
  description = "App server details"
  value = {
    app_server_1 = {
      id         = aws_instance.app_1.id
      private_ip = aws_instance.app_1.private_ip
    }
    app_server_2 = {
      id         = aws_instance.app_2.id
      private_ip = aws_instance.app_2.private_ip
    }
  }
}

output "rds_endpoint" {
  description = "RDS database endpoint"
  value       = aws_db_instance.main.endpoint
}

output "security_groups" {
  description = "Security group IDs"
  value = {
    alb_sg = aws_security_group.alb_sg.id
    web_sg = aws_security_group.web_sg.id
    app_sg = aws_security_group.app_sg.id
    db_sg  = aws_security_group.db_sg.id
  }
}

output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.main.id
}
