resource "google_project_service" "cert-manager" {
  service                    = "certificatemanager.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

locals {
  fqdn_no_dot = trimsuffix(local.domain_fqdn, ".")

  // SSL on `*.acme.com` does not cover `acme.com`, so the cert always carries both the wildcard and the apex.
  cert_domains = {
    wildcard = "*.${local.fqdn_no_dot}"
    apex     = local.fqdn_no_dot
  }
}

resource "google_certificate_manager_dns_authorization" "this" {
  for_each = local.cert_domains

  name        = "${local.resource_name}-${each.key}"
  labels      = local.labels
  description = "${each.value}: Created by Nullstone"
  domain      = each.value

  depends_on = [google_project_service.cert-manager]
}

resource "google_dns_record_set" "authorization_records" {
  provider = google.domain
  for_each = google_certificate_manager_dns_authorization.this

  managed_zone = local.domain_zone_id
  name         = each.value.dns_resource_record[0].name
  type         = each.value.dns_resource_record[0].type
  rrdatas      = [each.value.dns_resource_record[0].data]
  ttl          = 300
}

resource "google_certificate_manager_certificate" "this" {
  name        = local.resource_name
  labels      = local.labels
  description = "${local.block_name}: Wildcard + apex certificate for ${local.fqdn_no_dot}"
  scope       = var.scope == "" ? "DEFAULT" : var.scope

  managed {
    domains            = [for da in google_certificate_manager_dns_authorization.this : da.domain]
    dns_authorizations = [for da in google_certificate_manager_dns_authorization.this : da.id]
  }

  depends_on = [google_dns_record_set.authorization_records]
}

resource "google_certificate_manager_certificate_map" "this" {
  name        = local.resource_name
  labels      = local.labels
  description = "${local.block_name}: Created by Nullstone"

  depends_on = [google_project_service.cert-manager]
}

resource "google_certificate_manager_certificate_map_entry" "this" {
  name         = local.resource_name
  labels       = local.labels
  description  = "${local.block_name}: Created by Nullstone"
  map          = google_certificate_manager_certificate_map.this.name
  certificates = [google_certificate_manager_certificate.this.id]
  matcher      = "PRIMARY"
}
