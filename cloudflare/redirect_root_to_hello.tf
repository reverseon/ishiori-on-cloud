resource "cloudflare_ruleset" "redirect_root_to_hello" {
  zone_id     = cloudflare_zone.ishiori_net.id
  name        = "Redirect root to hello.ishiori.net"
  description = "Redirect ishiori.net to hello.ishiori.net using Cloudflare Ruleset"
  kind        = "zone"
  phase       = "http_request_redirect"

  rules = [
    {
      action = "redirect"
      action_parameters = {
        status_code = 301
        url         = "https://hello.ishiori.net/$uri$?$query$"
      }
      expression  = "http.host eq 'ishiori.net'"
      description = "Redirect root domain to hello.ishiori.net"
      enabled     = true
    }
  ]
}
