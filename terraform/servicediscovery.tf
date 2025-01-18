# Create a Private DNS Namespace for Service Discovery
resource "aws_service_discovery_private_dns_namespace" "private_dns_namespace" {
  name = "myapp.local"
  vpc  = data.aws_vpc.default.id
}

resource "aws_service_discovery_service" "backend_service" {
  name         = "backend"
  namespace_id = aws_service_discovery_private_dns_namespace.private_dns_namespace.id
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.private_dns_namespace.id
    dns_records {
      type = "A"
      ttl  = 60
    }
  }
  health_check_custom_config {
    failure_threshold = 3
  }
}
