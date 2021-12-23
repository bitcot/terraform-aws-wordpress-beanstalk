## WORDPRESS BEANSTALK MODULE
# This repository contains the terraform script for beanstalk environment with PHP application.

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
           # change the vaule accordingly 
            access_key                   = "<Access key of AWS account>"
            secret_key                   = "<Secret key of AWS account>"
            region_primary               = "<Region name>"
            stack                        = "<Name of application stack>"
            environment                  = "<Environment name>"
            application                  = "<Name of application>"
            ELB_certificate_arn          = "<Enter ELB_certificate_arn>" 
            codeprefix                   = "<S3 object key codeprefix where the git pull code is stored in S3 bucket Ex: username/reponame/branchname/username_reponame.zip >"
            dbname                       = "<Name for the RDS database>"
            dbadminuser                  = "<Username for the database>"
            db_instance_class            = <Instance type for RDS EX: db.t2.small>
            engine_version               = "<Version of database engine to use EX: 5.5.6, 8.0>"
            autoscaling_instance_type    = "<Instance type for the instance of Beanstalk application Ex: T2.medium>" 
            domain_name_cloudfront       = "<Aliase name for the Cloudfront domain>"
            cloudfront_cert_arn          = "<Enter cloudfront_cert_arn>"
            sns_email_id                 = "<Email id for sns alert>"
        }
        
    3. Insert the required variables values as shown above into this script.
    4. Then initialize and apply the terraform as,
             * terraform init
             * terraform plan 
             * terraform apply 
