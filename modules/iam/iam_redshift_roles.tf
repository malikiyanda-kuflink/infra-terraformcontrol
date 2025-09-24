# --------------------------------------------------------------------------
# Roles 
# --------------------------------------------------------------------------
resource "aws_iam_role" "redshift_role" {
  count = var.enable_redshift_role ? 1 : 0

  name = var.redshift_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = [
            "redshift.amazonaws.com",
            "scheduler.redshift.amazonaws.com"
          ]
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role" "redshift_dms_role" {
  count = var.enable_redshift_dms_role ? 1 : 0

  name = var.redshift_endpoint_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "dms.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# --------------------------------------------------------------------------
# Policies 
# --------------------------------------------------------------------------
resource "aws_iam_role_policy" "read_list_inline_policy" {
  count = var.enable_redshift_role ? 1 : 0
  name  = "${var.name_prefix}-redshift-read-list-policy"
  role  = aws_iam_role.redshift_role[0].id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::*",
          "arn:aws:s3:::*/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "redshift_combined_scheduler_policy" {
  name        = "${var.name_prefix}-Inline-RedshiftSchedulerCombinedPolicy"
  description = "Allows Redshift scheduled actions: pause/resume"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowPauseResume",
        Effect = "Allow",
        Action = [
          "redshift:PauseCluster",
          "redshift:ResumeCluster"
        ],
        Resource = "*"
      },
      {
        Sid    = "AllowScheduledActionManagement",
        Effect = "Allow",
        Action = [
          "redshift:DescribeClusters",
          "redshift:DescribeScheduledActions",
          "redshift:CreateScheduledAction",
          "redshift:DeleteScheduledAction",
          "redshift:ModifyScheduledAction"
        ],
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "dms_access_for_endpoint_attach" {
  count      = var.enable_redshift_dms_role ? 1 : 0
  role       = aws_iam_role.redshift_dms_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSRedshiftS3Role"
}

resource "aws_iam_role_policy_attachment" "attach_s3_readonly" {
  count      = var.enable_redshift_role ? 1 : 0
  role       = aws_iam_role.redshift_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# --------------------------------------------------------------------------
# scheduling 
# --------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "attach_combined_scheduler_policy" {
  count      = var.enable_redshift_role ? 1 : 0
  role       = aws_iam_role.redshift_role[0].name
  policy_arn = aws_iam_policy.redshift_combined_scheduler_policy.arn
}

resource "aws_iam_policy" "redshift_pause_resume_policy" {
  name        = "${var.name_prefix}-RedshiftPauseResumeMinimal"
  description = "Minimal policy to allow pause/resume of Redshift clusters"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "redshift:PauseCluster",
          "redshift:ResumeCluster"
        ],
        Resource = "*"
      }
    ]
  })
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "attach_redshift_pause_resume_minimal" {
  count      = var.enable_redshift_role ? 1 : 0
  role       = aws_iam_role.redshift_role[0].name
  policy_arn = aws_iam_policy.redshift_pause_resume_policy.arn
}