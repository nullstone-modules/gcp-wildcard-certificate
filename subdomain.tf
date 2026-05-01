data "ns_connection" "subdomain" {
  name     = "subdomain"
  contract = "*/gcp/cloud-dns"
}

locals {
  domain_fqdn    = data.ns_connection.subdomain.outputs.fqdn
  domain_zone_id = data.ns_connection.subdomain.outputs.zone_id

  // Delegator is emitted by the `domain/gcp/cloud-dns` contract but not by `subdomain/gcp/cloud-dns`.
  // When absent, the aliased provider falls back to ADC and the workspace's default project.
  delegator             = try(data.ns_connection.subdomain.outputs.delegator, null)
  delegator_project_id  = try(local.delegator["project_id"], null)
  delegator_impersonate = try(local.delegator["impersonate"], false) == true
  delegator_key_file    = try(base64decode(local.delegator["key_file"]), null)
  delegator_email       = try(local.delegator["email"], null)
}

// The root domain is typically managed in a separate GCP project from non-production environments,
// so DNS-authorization records may need to be written via a delegator service account.
// When no delegator is provided, all fields are null and this provider behaves like the default.
provider "google" {
  alias                       = "domain"
  project                     = local.delegator_project_id
  credentials                 = local.delegator_impersonate ? null : local.delegator_key_file
  impersonate_service_account = local.delegator_impersonate ? local.delegator_email : null
}
