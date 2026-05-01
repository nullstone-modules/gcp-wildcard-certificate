output "certificate_id" {
  value       = google_certificate_manager_certificate.this.id
  description = "string ||| The ID of the Certificate in GCP Certificate Manager. (Format: projects/{{project}}/locations/global/certificates/{{name}})"
}

output "certificate_map_id" {
  value       = google_certificate_manager_certificate_map.this.id
  description = "string ||| The ID of the Certificate Map in GCP Certificate Manager. (Format: projects/{{project}}/locations/global/certificateMaps/{{name}})"
}

output "certificate_map_name" {
  value       = google_certificate_manager_certificate_map.this.name
  description = "string ||| The name of the Certificate Map in GCP Certificate Manager."
}

output "certificate_domains" {
  value       = google_certificate_manager_certificate.this.san_dnsnames
  description = "list(string) ||| List of domains issued on the certificate."
}
