# ===================================================================
# RDS – Primary (restore vs fresh) as a single structured object
# ===================================================================

output "rds_primary" {
  description = "Primary RDS instance details (switches between restored and fresh)."
  value = {
    arn               = local.restore_rds_from_snapshot ? try(module.rds_restore[0].db_instance_arn, null) : try(module.rds[0].db_instance_arn, null)
    id                = local.restore_rds_from_snapshot ? try(module.rds_restore[0].db_instance_id, null) : try(module.rds[0].db_instance_id, null)
    identifier        = local.restore_rds_from_snapshot ? try(module.rds_restore[0].db_instance_identifier, null) : try(module.rds[0].db_instance_identifier, null)
    endpoint          = local.restore_rds_from_snapshot ? try(module.rds_restore[0].db_instance_endpoint, null) : try(module.rds[0].db_instance_endpoint, null)       # host:port
    address           = try(split(":", (local.restore_rds_from_snapshot ? module.rds_restore[0].db_instance_endpoint : module.rds[0].db_instance_endpoint))[0], null) # host only
    port              = local.mysql_port
    security_group_id = aws_security_group.rds_sg.id
    restored          = local.restore_rds_from_snapshot
    snapshot          = local.restore_rds_from_snapshot && local.db_snapshot_identifier != "" ? local.db_snapshot_identifier : null
  }
}

# ===================================================================
# RDS – Read Replica (optional) as a structured object (or null)
# ===================================================================

output "rds_replica" {
  description = "RDS read replica details (null when not created)."
  value = local.restore_rds_from_snapshot ? {
    arn        = try(module.rds_restore[0].db_replica_arn, null)
    id         = try(module.rds_restore[0].db_replica_id, null)
    identifier = try(module.rds_restore[0].db_replica_identifier, null)
    endpoint   = try(module.rds_restore[0].db_replica_endpoint, null) # host:port
    address    = try(split(":", module.rds_restore[0].db_replica_endpoint)[0], null)
    port       = local.mysql_port
  } : null
}

# ===================================================================
# Redshift – Cluster (restore vs fresh) as a single structured object
# ===================================================================

# Helper locals to pick the correct module outputs
locals {
  redshift_selected_arn        = local.enable_redshift ? (local.restore_redshift_from_snapshot ? try(module.redshift_restore[0].redshift_arn, null) : try(module.redshift[0].redshift_arn, null)) : null
  redshift_selected_identifier = local.enable_redshift ? (local.restore_redshift_from_snapshot ? try(module.redshift_restore[0].redshift_cluster_identifier, null) : try(module.redshift[0].redshift_cluster_identifier, null)) : null
  redshift_selected_endpoint   = local.enable_redshift ? (local.restore_redshift_from_snapshot ? try(module.redshift_restore[0].redshift_endpoint, null) : try(module.redshift[0].redshift_endpoint, null)) : null                 # host:port (may be null)
  redshift_selected_address    = local.enable_redshift ? (local.restore_redshift_from_snapshot ? try(module.redshift_restore[0].redshift_endpoint_address, null) : try(module.redshift[0].redshift_endpoint_address, null)) : null # host only (may be null)
}

output "redshift_cluster" {
  description = "Redshift cluster details (switches between restored and fresh; null if Redshift disabled)."
  value = local.enable_redshift ? {
    arn        = local.redshift_selected_arn
    identifier = local.redshift_selected_identifier

    # endpoint: prefer module endpoint; else build from address+port; else null
    endpoint = coalesce(
      local.redshift_selected_endpoint,
      local.redshift_selected_address != null ? format("%s:%d", local.redshift_selected_address, local.redshift_port) : null
    )

    # address: prefer module address; else derive from endpoint; else null
    address = coalesce(
      local.redshift_selected_address,
      local.redshift_selected_endpoint != null ? split(":", local.redshift_selected_endpoint)[0] : null
    )

    port     = local.redshift_port
    restored = local.restore_redshift_from_snapshot
    snapshot = local.restore_redshift_from_snapshot && local.redshift_snapshot_identifier != "" ? local.redshift_snapshot_identifier : null
  } : null
}



# ===================================================================
# Route 53 – MySQL CNAMEs grouped (live/test/green/blue) with targets
# ===================================================================

output "mysql_aliases" {
  description = "Switchable MySQL CNAMEs with their current targets."
  value = {
    live = {
      name   = aws_route53_record.live_mysql.name
      fqdn   = aws_route53_record.live_mysql.fqdn
      type   = aws_route53_record.live_mysql.type
      ttl    = aws_route53_record.live_mysql.ttl
      target = one(aws_route53_record.live_mysql.records)
    }
    live_ro = length(aws_route53_record.live_mysql_ro) > 0 ? {
      name   = aws_route53_record.live_mysql_ro[0].name
      fqdn   = aws_route53_record.live_mysql_ro[0].fqdn
      type   = aws_route53_record.live_mysql_ro[0].type
      ttl    = aws_route53_record.live_mysql_ro[0].ttl
      target = one(aws_route53_record.live_mysql_ro[0].records)
    } : null

    test = {
      name   = aws_route53_record.test_mysql.name
      fqdn   = aws_route53_record.test_mysql.fqdn
      type   = aws_route53_record.test_mysql.type
      ttl    = aws_route53_record.test_mysql.ttl
      target = one(aws_route53_record.test_mysql.records)
    }
    test_ro = length(aws_route53_record.test_mysql_ro) > 0 ? {
      name   = aws_route53_record.test_mysql_ro[0].name
      fqdn   = aws_route53_record.test_mysql_ro[0].fqdn
      type   = aws_route53_record.test_mysql_ro[0].type
      ttl    = aws_route53_record.test_mysql_ro[0].ttl
      target = one(aws_route53_record.test_mysql_ro[0].records)
    } : null

    green = {
      name   = aws_route53_record.green_mysql.name
      fqdn   = aws_route53_record.green_mysql.fqdn
      type   = aws_route53_record.green_mysql.type
      ttl    = aws_route53_record.green_mysql.ttl
      target = one(aws_route53_record.green_mysql.records)
    }
    green_ro = length(aws_route53_record.green_mysql_ro) > 0 ? {
      name   = aws_route53_record.green_mysql_ro[0].name
      fqdn   = aws_route53_record.green_mysql_ro[0].fqdn
      type   = aws_route53_record.green_mysql_ro[0].type
      ttl    = aws_route53_record.green_mysql_ro[0].ttl
      target = one(aws_route53_record.green_mysql_ro[0].records)
    } : null

    # BLUE uses count in your config – guard and index [0]
    blue = length(aws_route53_record.blue_mysql) > 0 ? {
      name   = aws_route53_record.blue_mysql[0].name
      fqdn   = aws_route53_record.blue_mysql[0].fqdn
      type   = aws_route53_record.blue_mysql[0].type
      ttl    = aws_route53_record.blue_mysql[0].ttl
      target = one(aws_route53_record.blue_mysql[0].records)
    } : null

    # If blue_mysql_ro also uses count in your code, mirror the pattern below.
    blue_ro = length(aws_route53_record.blue_mysql_ro) > 0 ? {
      name   = aws_route53_record.blue_mysql_ro[0].name
      fqdn   = aws_route53_record.blue_mysql_ro[0].fqdn
      type   = aws_route53_record.blue_mysql_ro[0].type
      ttl    = aws_route53_record.blue_mysql_ro[0].ttl
      target = one(aws_route53_record.blue_mysql_ro[0].records)
    } : null
  }
}

# ===================================================================
# Route 53 – Redshift CNAMEs grouped + addresses
# ===================================================================

output "redshift_aliases" {
  description = "Switchable Redshift CNAMEs with current targets and convenience addresses."
  value = {
    live = length(aws_route53_record.live_redshift) > 0 ? {
      name   = aws_route53_record.live_redshift[0].name
      fqdn   = aws_route53_record.live_redshift[0].fqdn
      type   = aws_route53_record.live_redshift[0].type
      ttl    = aws_route53_record.live_redshift[0].ttl
      target = one(aws_route53_record.live_redshift[0].records)
    } : null

    test = length(aws_route53_record.test_redshift) > 0 ? {
      name   = aws_route53_record.test_redshift[0].name
      fqdn   = aws_route53_record.test_redshift[0].fqdn
      type   = aws_route53_record.test_redshift[0].type
      ttl    = aws_route53_record.test_redshift[0].ttl
      target = one(aws_route53_record.test_redshift[0].records)
    } : null

    green = length(aws_route53_record.green_redshift) > 0 ? {
      name   = aws_route53_record.green_redshift[0].name
      fqdn   = aws_route53_record.green_redshift[0].fqdn
      type   = aws_route53_record.green_redshift[0].type
      ttl    = aws_route53_record.green_redshift[0].ttl
      target = one(aws_route53_record.green_redshift[0].records)
    } : null

    blue = length(aws_route53_record.blue_redshift) > 0 ? {
      name   = aws_route53_record.blue_redshift[0].name
      fqdn   = aws_route53_record.blue_redshift[0].fqdn
      type   = aws_route53_record.blue_redshift[0].type
      ttl    = aws_route53_record.blue_redshift[0].ttl
      target = one(aws_route53_record.blue_redshift[0].records)
    } : null

    # Convenience host-only addresses (no port); 'active' via LIVE alias
    addresses = {
      green  = length(aws_route53_record.green_redshift) > 0 ? trimsuffix(one(aws_route53_record.green_redshift[0].records), ".") : null
      blue   = length(aws_route53_record.blue_redshift) > 0 ? trimsuffix(one(aws_route53_record.blue_redshift[0].records), ".") : null
      active = length(aws_route53_record.live_redshift) > 0 ? trimsuffix(one(aws_route53_record.live_redshift[0].records), ".") : null
    }
  }
}

# ===================================================================
# Stable DNS for live MySQL (your existing computed name)
# ===================================================================

output "db_dns_instance_endpoint" {
  description = "Stable DNS name for the live MySQL endpoint in the kuflink zone."
  value = format(
    "kuff-%s-mysql.%s",
    local.env,
    trimsuffix(data.aws_route53_zone.kuflink.name, ".")
  )
}

output "db_ro_dns_instance_endpoint" {
  description = "Stable DNS name for the live MySQL endpoint in the kuflink zone."
  value = format(
    "kuff-%s-mysql-ro.%s",
    local.env,
    trimsuffix(data.aws_route53_zone.kuflink.name, ".")
  )
}

# ===================================================================
# Networking (kept simple)
# ===================================================================

output "vpc_private_route_table_id" {
  description = "ID of the private Route Table used by database subnets (from the networking layer)."
  value       = data.terraform_remote_state.foundation.outputs.private_rt_id
}

