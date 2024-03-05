resource "aws_iam_policy" "testPolicy" {
  name   = var.policyName
  policy = file("policy.json")
}

resource  "aws_iam_role" "testRole"{
    name= var.roleName
    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
    depends_on = [
        aws_iam_policy.testPolicy
    ]
}

resource "aws_iam_role_policy_attachment" "testAttachment" {
    role =  aws_iam_role.testRole.name
    policy_arn = aws_iam_policy.testPolicy.arn
    depends_on = [
        aws_iam_policy.testPolicy,aws_iam_role.testRole
    ]

}
output "policyArn" {
    value = aws_iam_policy.testPolicy.arn
}