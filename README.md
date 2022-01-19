# WORDPRESS BEANSTALK MODULE

# This repository contains the terraform script for beanstalk environment with PHP application with multiple environments creation.

# Here, by giving environments name in variable section, it creates the multiple environments (dev,stg,prod) accordingly.

# This includes
    1.AWS Beanstalk deployed on Default VPC
    2.RDS (MySQL) 
    3.Code Deployment process using code build , Code pipeline
    4.S3 bucket for media storage
    5.Cloudfront for serving media

# To use this script as a terraform module,
    1. Create a file named as main.tf
    2. Then add the below script,
   
    module "wordpress-beanstalk" {
        source  = "bitcot/wordpress-beanstalk/aws"
        version = "<Change version as per modules version>"
       # change the value accordingly 
        access_key                   = "<Access key of AWS account>"
        secret_key                   = "<Secret key of AWS account>"
        region_primary               = "<Region name>"
        stack                        = "<Name of application stack>"
        environment                  = "<Environments name EX: ["dev","stg"]>"
        elb_certificate_arn          = "<Enter ELB_certificate_arn>" 
        S3ObjectKey                  =  <Enter the S3 object key where code is located> 
        EX: {
            "dev" = "username/reponame/branchname/username_reponame.zip"
            "stg" = "username/reponame/branchname/username_reponame.zip"
        }
        elb_domains                  = "<ELB domain names for multi environments EX: ["dev.domain.com","stg.domain.com"]>"
        dbadminuser                  = "<Username for the database>"
        db_instance_class            = <Instance type for RDS EX: db.t2.small>
        engine_version               = "<Version of database engine to use EX: 5.5.6, 8.0>"
        autoscaling_instance_type    = "<Instance type for the instance of Beanstalk application Ex: t2.medium>" 
        domain_name_cloudfront       = "<Aliase name for the Cloudfront domain>"
        cdn_cert_arn                 = "<Enter cloudfront_cert_arn>"
        aws_db_parameter_group_family = "<aws_db_parameter_group_family version we need to pass here for ex: mysql5.7, mysql8.0>"
        sns_email_id                 = "<Enter the email id to receive alert notifications>"
    }
    
3. Insert the required variables values as shown above into this script.
4. Then initialize and apply the terraform as,

         * terraform init
         * terraform plan 
         * terraform apply 

5. To destroy the created infrastructure,

         * terraform destroy
         
# To get the outputs, 
    
    1. Create a file called outputs.tf along with main.tf creation.
    2. Then add the below script there into the outputs.tf

        output "loadbalancer_url" {
          description = "load balancer url"
          value = module.wordpress-beanstalk.loadbalancer_url
        }