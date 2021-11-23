#################### WORDPRESS BEANSTALK MODULE #######################
​
# This repository contains the terraform script for beanstalk environment with PHP application.
​
# This includes, 
    1.AWS Beanstalk
    2.RDS (MySQL)
    3.CodeX Tools
    4.S3 bucket for media
    5.Cloudfront for media
    6.ACM (CF + ALB)
    7.VPC (Default one)
​
# To use this script without using as a module, 
​
    1. Clone the repository to your local machine.
    2. Add the values for the variables in variables.tf file
    3. The input variables needed to enter are,
     
          * access_key                   - Access key of AWS account
          * secret_key                   - Secret key of AWS account
          * region_primary               - Region name
          * stack                        - Name of application stack
          * environment                  - Environment name
          * application                  - Name of application 
          * domain_name                  - Domain name for the ELB
          * domain_name_cloudfront       - Domain name for the Cloudfront
          * codeprefix                   - S3 object key codeprefix where the code is stored in S3 bucket.
          * dbname                       - Name for the RDS database
          * dbadminuser                  - Username for the database
          * db_instance_class            - Instance type for RDS
          * engine_version               - DB engine version
          * autoscaling_instance_type    - Instance type for the instance of Beanstalk application 
​
    4. After including the variables, enter
            
          * terraform init
          * terraform plan
          * terraform apply 
​
# To use this script as a terraform module, 
​
    1. Create a file named as main.tf
    2. Then add the below script,
       
            module "wordpress-bs" {
            source  = "app.terraform.io/bitcot/wordpress-bs/aws"
            version = "1.0.9"                        # change it depends on the version of code.
​
            # insert required variables here    
            
            }
​
    3. Insert the required variables values as shown above into this script.
    4. Then initialize and apply the terraform as,
​
            * terraform init
            * terraform plan 
            * terraform apply 
