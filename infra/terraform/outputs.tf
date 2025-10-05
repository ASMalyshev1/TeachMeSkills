output "portal_public_ip"   { value = yandex_compute_instance.web_portal.network_interface[0].nat_ip_address }
output "gitlab_public_ip"   { value = yandex_compute_instance.ci_gitlab.network_interface[0].nat_ip_address }
output "grafana_private_ip" { value = yandex_compute_instance.mon_grafana.network_interface[0].ip_address }
output "elk_ip"             { value = yandex_compute_instance.logs_elk.network_interface[0].ip_address }

output "public_fqdns" {
  value = {
    portal  = yandex_dns_recordset.pub_portal.name
    grafana = yandex_dns_recordset.pub_grafana.name
    gitlab  = yandex_dns_recordset.pub_gitlab.name
    elk     = yandex_dns_recordset.pub_elk.name
  }
}
