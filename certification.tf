resource "tls_private_key" "lab7_key" {
  algorithm = "RSA"
  rsa_bits = "2048"
}

resource "tls_self_signed_cert" "lab7_cert" {
  # key_algorithm   = tls_private_key.lab7_key.algorithm
  private_key_pem = tls_private_key.lab7_key.private_key_pem

  # Certificate expires after 7 days.
  validity_period_hours = 168

  # Generate a new certificate if Terraform is run within 2 days
  # of the certificate's expiration time.
  early_renewal_hours = 48

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  subject {
    common_name = "lab7-website.com"
    organization = "Shaul Hobbies TLD"
    country = "IL"
  }

  dns_names = [ aws_lb.lab7_lb.dns_name ] 
}

resource "aws_acm_certificate" "lab7_cert" {
  certificate_body = tls_self_signed_cert.lab7_cert.cert_pem
  private_key      = tls_private_key.lab7_key.private_key_pem

  tags = {
    Project = "lab7"
    Name = "lab7-website"
  }
}