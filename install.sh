#!/usr/bin/env bash
if [ "$(id -u)" != "0" ]; then
  echo "This command must be run as root" 1>&2
  exit 1
fi

add-apt-repository --yes --no-update ppa:certbot/certbot
apt update
apt install -y python-certbot-nginx nginx haveged
if [ -z "$1" ]; then
  letsencrypt register --agree-tos --no-eff-email
else
  letsencrypt register --non-interactive --no-eff-email --agree-tos -m $1
fi
cat >>/etc/letsencrypt/cli.ini <<EOF

# Use a 4096 bit RSA key instead of 2048
rsa-key-size = 4096
EOF

cp ssl_{setup,renew,dhparam} /usr/local/bin
chmod 755 /usr/local/bin/ssl_{setup,renew,dhparam}
cp -r var /
read -p "Do you want to generate a Diffie Hellman? " -n 1 -r
echo # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]; then
  ssl_dhparam
else
  echo "You can still generate a Diffie Hellman later on by runnning : ssl_dhparam"
fi

grep "gzip_disable \"msie6\"" /etc/nginx/nginx.conf >>/dev/null || sed -i -e "s/gzip on;/gzip on;\n\tgzip_disable \"msie6\";/" /etc/nginx/nginx.conf
sed -i "s/# gzip/gzip/" /etc/nginx/nginx.conf

which ufw || apt install -y ufw
ufw allow 'OpenSSH'
ufw allow 'Nginx Full'
ufw delete allow 'Nginx HTTP'
echo "y" | ufw enable
