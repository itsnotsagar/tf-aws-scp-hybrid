resource "aws_organizations_policy" "this" {
  provider    = aws.target
  for_each    = fileset(path.root, "${local.policies_directory}/*.json")
  name        = trimprefix(trimsuffix(each.value, ".json"), "${local.policies_directory}/")
  content     = file(each.value)
  type        = var.policy_type
  description = var.description
}

module "policy_attach" {
  depends_on              = [aws_organizations_policy.this]
  source                  = "./modules/policy_attach"
  for_each                = local.ou_map
  ou                      = each.key
  policies                = each.value
  policy_id               = aws_organizations_policy.this
  policies_directory_name = local.policies_directory

  providers = {
    aws = aws.target
  }
}
