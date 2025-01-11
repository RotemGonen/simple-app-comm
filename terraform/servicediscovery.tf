# Create a Private DNS Namespace for Service Discovery
resource "aws_service_discovery_private_dns_namespace" "private_dns_namespace" {
  name = "myapp.local"
  vpc  = data.aws_vpc.default.id
}

