#!/usr/bin/env bash

# get AWS instance ip address
ipv4=$(curl -s 169.254.169.254/latest/meta-data/public-ipv4)
ipv6=$(curl -s 169.254.169.254/latest/meta-data/ipv6)

### godaddy_domain="<your-domain>"
### godaddy_api_secret="<key:secret>"

# godaddy renew DNS A record @
curl -X PUT "https://api.godaddy.com/v1/domains/$godaddy_domain/records/A/%40" \
-H "Authorization: sso-key $godaddy_api_secret" \
-H "Content-Type: application/json" \
-d '[{"data":"'$ipv4'"}]'

# godaddy renew DNS AAAA record @
curl -X PUT "https://api.godaddy.com/v1/domains/$godaddy_domain/records/AAAA/%40" \
-H "Authorization: sso-key $godaddy_api_secret" \
-H "Content-Type: application/json" \
-d '[{"data":"'$ipv6'"}]'
