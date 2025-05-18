#!/bin/bash

echo_info() {
  echo -e "\033[1;32m[INFO]\033[0m $1"
}
echo_error() {
  echo -e "\033[1;31m[ERROR]\033[0m $1"
  exit 1
}

apt-get update; apt-get install curl socat git nload speedtest-cli -y

if ! command -v docker &> /dev/null; then
  curl -fsSL https://get.docker.com | sh || echo_error "Docker installation failed."
else
  echo_info "Docker is already installed."
fi

rm -r Marzban-node

git clone https://github.com/Gozargah/Marzban-node

rm -r /var/lib/marzban-node

mkdir /var/lib/marzban-node

rm ~/Marzban-node/docker-compose.yml

cat <<EOL > ~/Marzban-node/docker-compose.yml
services:
  marzban-node:
    image: gozargah/marzban-node:latest
    restart: always
    network_mode: host
    environment:
      SSL_CERT_FILE: "/var/lib/marzban-node/ssl_cert.pem"
      SSL_KEY_FILE: "/var/lib/marzban-node/ssl_key.pem"
      SSL_CLIENT_CERT_FILE: "/var/lib/marzban-node/ssl_client_cert.pem"
      SERVICE_PROTOCOL: "rest"
    volumes:
      - /var/lib/marzban-node:/var/lib/marzban-node
EOL
curl -sSL https://raw.githubusercontent.com/Tozuck/Node_monitoring/main/node_monitor.sh | bash
rm /var/lib/marzban-node/ssl_client_cert.pem

cat <<EOL > /var/lib/marzban-node/ssl_client_cert.pem
-----BEGIN CERTIFICATE-----
MIIEnDCCAoQCAQAwDQYJKoZIhvcNAQENBQAwEzERMA8GA1UEAwwIR296YXJnYWgw
IBcNMjUwNTE4MjIzMjA0WhgPMjEyNTA0MjQyMjMyMDRaMBMxETAPBgNVBAMMCEdv
emFyZ2FoMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAuVQYPkq966Sx
aFBA18YzLjPx1bcH8FS3a4Lp4a/Ad6mIFA+oNxC+kogjIsHu7vzBH8eQwtVcK88B
7EpLrOOuEAAGktFhYIGssZIwe/EHGoK/Jt2n8TnT0cfdKLgC6OxtWmkThmPv1pAS
DULwGFlot9du5R3NwmtATrujy62WsZqtkFt/dg6CKtztnXVEb6FX5SKDkjY33LTv
RytKJp747Wirh/aEQFvGIwSHP6ibHMMVyHh8Vsq58NNsTekJYo10bnyn0T+RiSkA
doR8kPW14oBt09Lfa4Vb0xMvn7DxWdKmhXIAxLL5KMAxzK9WvwmTrENsP+8f1THr
ONuuf4A8jaUPRSFS99XFgE/ZkLxiTO9ATLnLdYioLK1lAXrrrrM6U8Huhi0iZ2VU
hx7mrz++jwI6ujwbewxN0jrjS4asFcEE68WFg8NqkJTpd21uZKZvLG0RtyTOm2vs
64UmV4XViDgPSN1jErt53doTzLyxFEu4jCvFH4NaQteBlBuuxGnAXOmHz/AkRZRn
D1Tz8co0ZmX2zrGIQCRe6OtB/J9qBIYgWxL1N6urD6dlEJY8sW1/HSiDAYIz4OBk
Cgtn2ZUU/KwyMqbW0AGLuyOq1r3lZhdkPIWaQk7Io5VGqEqdnF0CtQMkFOAq3IeR
GddqzWsyoxksKIh8EKqLDivOkTDoZJkCAwEAATANBgkqhkiG9w0BAQ0FAAOCAgEA
ORHrmY+Tqg6TppYoS7FuzMK0/2S5SNUMnTzQT9qEZz3sB2Q3TfrRF3cNfre8fqGI
y1b/QUa9S0J0X9turSMrEi+RBs57G8VtM1HvgNwZLmIEm8+/tV8tBtiJzaghb8gI
mflccQKC+qFCVLiHdRbC1i8T3VUR8IT4+0R5IN9ayUFew9wR3+/2WO5+/sxlT3+m
SxkgixnPkMfbA2vi+FaX+oRbLdxy6BmC82YvO39t+taGEVsM4oDua1LvkDSnKPSI
pYeHYuKeIL34o/wqnpebLHOzqGi36j4wACNqHjUgBoOBJQdpvNGQnWSpw+1v/OIl
ivVIRdPjUjg/cyUEo6w9jjFVqOO/x/SqYcdp/X9H9lzl2SXe/ZtmrphlZEbQCrlE
v26WGoJIXg87ZDHAtRiZK53dxCQ7oTSdhK3nVX32yuxDEgsF1RdBpG85Rp2xxmKa
h706YY6fLFc437+lt9QfBmeNqECAKWSa43G30gLV0/aQYPBFjUOeR/JpF3x7WDeB
S4oIwgY4S47SyrlKeCTND5OMtXQHrNJpih7WFTPnSVtjbRSNHDQOiHTbtGiEpqOp
BpRP9Th3bGKDrkIsILdC8WYGULPNGN6kv16+S1iAwLvtJ2l0rsEUQkwrqeERwtX1
xbulcjQlYeCOXFJ0qKSNK9mRJhzMeSP5VepAyUr5wUY=
-----END CERTIFICATE-----
EOL

cd ~/Marzban-node
docker compose up -d

echo_info "Finalizing UFW setup..."

ufw allow 22
ufw allow 80
ufw allow 2096
ufw allow 2053
ufw allow 62050
ufw allow 62051

ufw --force enable
ufw reload
speedtest
