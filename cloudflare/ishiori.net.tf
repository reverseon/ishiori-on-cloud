resource "cloudflare_zone" "ishiori_net" {
  account = {
    id = "57cf579ea376c163634edd1e40c36116"
  }
  name = "ishiori.net"
}

# There is two unmanaged DNS records, for *.otaprv and otaprv.ishiori.net. because it is integral to the DNS setup.

resource "cloudflare_dns_record" "tokyo1_gateway_ishiori_net_A" {
  zone_id = cloudflare_zone.ishiori_net.id
  name    = "tokyo1.gateway.ishiori.net"
  type    = "A"
  content = "198.13.42.47"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "wild_ishiori_net_CNAME" {
  zone_id = cloudflare_zone.ishiori_net.id
  name    = "*.ishiori.net"
  type    = "CNAME"
  content = "tokyo1.gateway.ishiori.net"
  ttl     = 1
  proxied = true
}


resource "cloudflare_dns_record" "wild_mizuki_otaprv_ishiori_net_A" {
  zone_id = cloudflare_zone.ishiori_net.id
  name    = "*.mizuki.otaprv.ishiori.net"
  type    = "A"
  content = "192.168.1.249"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "root_ishiori_net_A" {
  zone_id = cloudflare_zone.ishiori_net.id
  name    = "ishiori.net"
  type    = "A"
  content = "192.0.2.1"
  ttl     = 1
  proxied = true
}

resource "cloudflare_dns_record" "wild_hana_ishiori_net_CNAME" {
  zone_id = cloudflare_zone.ishiori_net.id
  name    = "*.hana.ishiori.net"
  type    = "CNAME"
  content = "tokyo1.gateway.ishiori.net"
  ttl     = 1
  proxied = true 
}