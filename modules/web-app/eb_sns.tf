resource "aws_sns_topic" "eb_notifications" {
  name = "ElasticBeanstalkNotifications-Deployments-Kuflink-dev-test-web-env"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.eb_notifications.arn
  protocol  = "email"
  endpoint  = "m.iyanda@kuflink.com"
}

# resource "aws_sns_topic_policy" "eb_sns_policy" {
#   arn = "${aws_sns_topic.eb_notifications.arn}"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           AWS = "${aws_iam_role.eb_role.arn}"  
#         }
#         Action = "sns:Publish"
#         Resource = "${aws_sns_topic.eb_notifications.arn}"
#       }
#     ]
#   })
# }


