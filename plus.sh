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
IBcNMjUwMzI2MDAzMDA0WhgPMjEyNTAzMDIwMDMwMDRaMBMxETAPBgNVBAMMCEdv
emFyZ2FoMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA4cm9yAbu12g6
uAL4TZz9eB6t58Bv0e3OWmbaheTzxCNO2d5XskwVTH5FaB0F8fQjC+vm6lCraTKK
G1bbFcYt1X7U+Z6UimdILYxwkFkc4FmzrfeeMLR9zBxGuUQe26iFFvYKb6pU/mRr
co7kohX5pX5iB0rTeOvywmZUZpbsBYBeTK1CMOb6Y24E42c0A80j+ipzVRDz/6qb
Le86Hnl2qD3w38UshiLYtMRBV+TfKInyWFC6VzQ3+SEwdjMcZDpMTVNaPnt27lhD
hfvbpmfwtzhu5NRKRFQInr8VsbIvBfYRZSW/+1PaTl0jqqUexPUB4R/YM+rWMZS7
aZIo+9VD4O1DuDFi3pLa+nGdnlEDibSRPbOvgn32yAK7egG13ZA+7riS0z7DiChN
AH4GSuUTTgkve9H70ArHBQ+/LTSDlycJ1uuArQ42Wm7mp1Md3Rm8b6ysH4XUUJhY
dbdQx4kcb1xMZR47iy+O5Zf0LNkX3KO8rCGi5Y3K5mpgvpTpMjxPO3/uyJUrQdiB
IBvAjJnyWkiNNeQYyd6hbs3ATxwxhdMaj2G6la+0vtSKWDO0Ej7ApYWNIZQQymmW
dfQ2aABNB0/xRNCPn36zL+s86dIeLKBpfsNgQSl111vn+Eo3mRaLjtFLPu7ptOsG
BwBv5wQyGiEr/3VY58qaC74moKoFk2ECAwEAATANBgkqhkiG9w0BAQ0FAAOCAgEA
Lk2bH9hWlCh98UOhagoYD10w/MeLY9AXZhX4zO5UXTh8vGI9T0GdOrP3RwqWBifH
YO01i1sq2+NYGK2IhSvM8oO+l5p0U9ZdOQuEWyZAPjBW7QDJ4HFWZEugR8LaLyVQ
H5hhQ0WWMIJweP3V8rDkHjJVVtWCfecqGIXN+uVACGFd+WMz2mS5/Iq98+AWTllW
iZItY4vYefMfzhgSda5KH9Ns+okXxRLT0+veqVC+XJJTfbrEyIqACEiowQA4xwOM
hXYs7uzWqZ4QY55v7zd/6q2bu6CQ5M7yDmvw+6qlCDmuE0zLRNe0GmB23EoVEm9E
Kvtl8K1gt0G+lmyQZRUTj0/lFMY7Mu9blK68U4d/pZjTfLn276JBHwChhqX2pNRI
Y6uz1yA5Y4oof2yEtXXJgB71gaqVYYm0ed3XgM03e0cDB6BLU3iTbLlUite8qtHC
OLN3yz9hZC6oGLPI5RZlDhJgsk9A6BhY21o4YejvpKf0rGhak3Y2tpQYRDy8XLiF
3Pn9Ao9Dnn6nkXvUcm27CpJlY/UOA+rrhIgRc6/ofydR0rxk4JBwfs3vl4S3uufz
62kNUQOcPdk80s/W7i9S/h0xOtxPLRyt+GDz+CUI454KYn+suBwBqzFpnID/+PFk
Axte9/Qc7S2vSdkcgq3Xd+1TA69sErRlegSS80ukZwY=
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
