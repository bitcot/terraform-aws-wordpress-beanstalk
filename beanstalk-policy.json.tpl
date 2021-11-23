{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "SNS",
            "Effect": "Allow",
            "Action": [
                "sns:Publish"
            ],
            "Resource": "arn:aws:sns:${region}:${account_id}:${stack}-${environment}-${application}-*"
        }
    ]
}
