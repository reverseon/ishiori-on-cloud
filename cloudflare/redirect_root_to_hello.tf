resource "cloudflare_page_rule" "redirect_root_to_hello" {
  zone_id = cloudflare_zone.ishiori_net.id
  target  = "ishiori.net/*"
  actions = {
    forwarding_url = {
      url         = "https://hello.ishiori.net/$1"
      status_code = 301
    }
  }
}
