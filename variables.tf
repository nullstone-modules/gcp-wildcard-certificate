variable "scope" {
  type        = string
  default     = ""
  description = <<EOF
The scope of the certificate.
- "":            (default) For use with Load Balancing and Cloud CDN
- "ALL_REGIONS": For use with cross-region internal application load balancing
- "EDGE_CACHE":  For use with media edge services
EOF

  validation {
    condition     = contains(["EDGE_CACHE", "ALL_REGIONS", ""], var.scope)
    error_message = "scope must be one of \"EDGE_CACHE\", \"ALL_REGIONS\", or \"\"."
  }
}
