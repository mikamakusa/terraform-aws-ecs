resource "aws_kms_key" "this" {
  count                    = length(var.kms_key)
  customer_master_key_spec = lookup(var.kms_key[count.index], "customer_master_key_spec")
  deletion_window_in_days  = lookup(var.kms_key[count.index], "deletion_window_in_days")
  description              = lookup(var.kms_key[count.index], "description")
  enable_key_rotation      = lookup(var.kms_key[count.index], "enable_key_rotation")
  is_enabled               = lookup(var.kms_key[count.index], "is_enabled")
  key_usage                = lookup(var.kms_key[count.index], "key_usage")
  policy                   = lookup(var.kms_key[count.index], "policy")
  tags = merge(
    var.tags,
    lookup(var.kms_key[count.index], tags),
    data.aws_default_tags.this.tags
  )
  bypass_policy_lockout_safety_check = lookup(var.kms_key[count.index], "bypass_policy_lockout_safety_check")
  custom_key_store_id                = lookup(var.kms_key[count.index], "custom_key_store_id")
  multi_region                       = lookup(var.kms_key[count.index], "multi_region")
  rotation_period_in_days            = lookup(var.kms_key[count.index], "rotation_period_in_days")
  xks_key_id                         = lookup(var.kms_key[count.index], "xks_key_id")
}

resource "aws_kms_key_policy" "this" {
  count = length(var.kms_key) == 0 ? 0 : length(var.kms_key_policy)
  key_id = try(
    element(aws_kms_key.this.*.id, lookup(var.kms_key_policy[count.index], "key_id"))
  )
  policy                             = lookup(var.kms_key_policy[count.index], "policy")
  bypass_policy_lockout_safety_check = lookup(var.kms_key_policy[count.index], "bypass_policy_lockout_safety_check")
}