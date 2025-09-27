data "aws_route53_zone" "kuflink" {
  name         = local.aws_route53_zone  #"brickfin.co.uk"
  private_zone = false
}

# ---------------------------------------------------------------------------------------------------
# ❌ DO NOT TOUCH LIVE SYSTEMS - 🔁 SWITCHABLE ALIASES (Points to green or blue)
# ---------------------------------------------------------------------------------------------------

resource "aws_route53_record" "live_mysql" {
  zone_id = data.aws_route53_zone.kuflink.zone_id
  name    = "kuff-${local.env}-mysql"
  type    = "CNAME"
  ttl     = 60
  records = [
    local.active_color == "green" ?
    aws_route53_record.green_mysql.fqdn :
    aws_route53_record.blue_mysql[0].fqdn
  ]
}


resource "aws_route53_record" "live_mysql_ro" {
  # Create this alias only if the target exists:
  # - if live=green → require green replica to exist
  # - if live=blue  → always (blue_mysql_ro exists unconditionally)
  count = lower(local.active_color) == "green" ? (local.create_read_replica ? 1 : 0) : 1

  zone_id = data.aws_route53_zone.kuflink.zone_id
  name    = "kuff-${local.env}-mysql-ro"
  type    = "CNAME"
  ttl     = 60
  records = [
    lower(local.active_color) == "green"
    ? aws_route53_record.green_mysql_ro[0].fqdn
    : aws_route53_record.blue_mysql_ro[0].fqdn
  ]
}



# LIVE alias (only when Redshift is enabled) — NOTE the [0] index
resource "aws_route53_record" "live_redshift" {
  count   = local.enable_redshift ? 1 : 0
  zone_id = data.aws_route53_zone.kuflink.zone_id
  name    = "kuff-${local.env}-redshift"
  type    = "CNAME"
  ttl     = 60
  records = [
    lower(local.active_color) == "green"
    ? aws_route53_record.green_redshift[0].fqdn
    : aws_route53_record.blue_redshift[0].fqdn
  ]
}


# ---------------------------------------------------------------------------------------------------
# ✅ NEW BLUE/GREEN DEPLOYMENT 
# ---------------------------------------------------------------------------------------------------

# ----------------------------
# GREEN (New DBs from Modules)
# ----------------------------
# Primary CNAME: prefer restored DB, else fresh DB
resource "aws_route53_record" "green_mysql" {
  zone_id = data.aws_route53_zone.kuflink.zone_id
  name    = "green-kuff-${local.env}-mysql"
  type    = "CNAME"
  ttl     = 60
  records = [
    replace(
      local.restore_rds_from_snapshot
      ? module.rds_restore[0].db_instance_endpoint
      : module.rds[0].db_instance_endpoint,
      "/:[0-9]+$/",
      ""
    )
  ]
}



# # # Read-only CNAME: create only if a replica exists in either module
resource "aws_route53_record" "green_mysql_ro" {
  # use the same flag you pass into the modules
  count = local.create_read_replica ? 1 : 0

  zone_id = data.aws_route53_zone.kuflink.zone_id
  name    = "green-kuff-${local.env}-mysql-ro"
  type    = "CNAME"
  ttl     = 60
  records = [
    replace(
      local.restore_rds_from_snapshot
      ? module.rds_restore[0].db_replica_endpoint
      : module.rds[0].db_replica_endpoint,
      "/:[0-9]+$/",
      ""
    )
  ]
}


resource "aws_route53_record" "green_redshift" {
  count   = local.enable_redshift ? 1 : 0
  zone_id = data.aws_route53_zone.kuflink.zone_id
  name    = "green-kuff-${local.env}-redshift"
  type    = "CNAME"
  ttl     = 60
  records = [
    replace(
      local.restore_redshift_from_snapshot
      ? module.redshift_restore[0].redshift_endpoint_address
      : module.redshift[0].redshift_endpoint_address,
      "/:[0-9]+$/",
      ""
    )
  ]
}

# ----------------------------
# BLUE (Legacy)
# ----------------------------
# If you build Blue Route53 records from legacy hosts:
resource "aws_route53_record" "blue_mysql" {
  count   = 1
  zone_id = data.aws_route53_zone.kuflink.zone_id
  name    = "blue-kuff-${local.env}-mysql"
  type    = "CNAME"
  ttl     = 60
  records = [local.blue_mysql_host]
}

resource "aws_route53_record" "blue_mysql_ro" {
  count   = 1
  zone_id = data.aws_route53_zone.kuflink.zone_id
  name    = "blue-kuff-${local.env}-mysql-ro"
  type    = "CNAME"
  ttl     = 60
  records = [local.blue_mysql_ro_host]
}

resource "aws_route53_record" "blue_redshift" {
  count   = local.enable_redshift ? 1 : 0
  zone_id = data.aws_route53_zone.kuflink.zone_id
  name    = "blue-kuff-${local.env}-redshift"
  type    = "CNAME"
  ttl     = 60
  records = ["no-${local.env}-redshift-cluster"]
}
# -----------------------------------------------------------
# 🔁 SWITCHABLE TEST ALIASES (Points to green or blue)
# -----------------------------------------------------------
resource "aws_route53_record" "test_mysql" {
  zone_id = data.aws_route53_zone.kuflink.zone_id
  name    = "test-kuff-${local.env}-mysql"
  type    = "CNAME"
  ttl     = 60
  records = [
    lower(local.test_active_color) == "green"
    ? trimsuffix(aws_route53_record.green_mysql.fqdn, ".")
    : trimsuffix(
      try(aws_route53_record.blue_mysql[0].fqdn, "no-blue-mysql-db-available."),
      "."
    )
  ]
}

resource "aws_route53_record" "test_mysql_ro" {
  # Create only when:
  # - test color is green AND you actually create a green replica, OR
  # - test color is blue (always create the alias)
  count = lower(local.test_active_color) == "green" ? (local.create_read_replica ? 1 : 0) : 1

  zone_id = data.aws_route53_zone.kuflink.zone_id
  name    = "test-kuff-${local.env}-mysql-ro"
  type    = "CNAME"
  ttl     = 60
  records = [
    lower(local.test_active_color) == "green"
    # green path: count ensures green_mysql_ro[0] exists
    ? aws_route53_record.green_mysql_ro[0].fqdn
    # blue path: blue_mysql_ro might have count = 0 → guard + fallback
    : (
      length(aws_route53_record.blue_mysql_ro) > 0
      ? aws_route53_record.blue_mysql_ro[0].fqdn
      : format(
        "blue-kuff-%s-mysql-ro.%s",
        local.env,
        trimsuffix(data.aws_route53_zone.kuflink.name, ".")
      )
    )
  ]
}



# TEST alias (only when Redshift is enabled) — NOTE the [0] index
resource "aws_route53_record" "test_redshift" {
  count   = local.enable_redshift ? 1 : 0
  zone_id = data.aws_route53_zone.kuflink.zone_id
  name    = "test-kuff-${local.env}-redshift"
  type    = "CNAME"
  ttl     = 60
  records = [
    lower(local.test_active_color) == "green"
    ? aws_route53_record.green_redshift[0].fqdn
    : aws_route53_record.blue_redshift[0].fqdn
  ]
}