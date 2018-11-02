#!/usr/bin/env bash
if [ "$(id -u)" != "0" ]; then
  echo "This command must be run as root" 1>&2
  exit 1
fi

cp ssl_{setup,renew,dhparam} /usr/local/bin
chmod 755 /usr/local/bin/ssl_{setup,renew,dhparam}
cp -r var /

add-apt-repository --yes --no-update ppa:certbot/certbot
apt update
apt install -y python-certbot-nginx nginx haveged

# configure letsencrypt
if [ -z "$1" ]; then
  letsencrypt register --agree-tos --no-eff-email
else
  letsencrypt register --non-interactive --no-eff-email --agree-tos -m $1
fi
cat >>/etc/letsencrypt/cli.ini <<EOF

# Use a 4096 bit RSA key instead of 2048
rsa-key-size = 4096
EOF
cp /etc/letsencrypt/options-ssl-nginx.conf /etc/letsencrypt/options-ssl-nginx.conf.bkp
cp /var/lib/ssl_setup/options-ssl-nginx.conf /etc/letsencrypt/options-ssl-nginx.conf

# enable gzip in nginx
if [ -z "$1" ]; then
  read -p "Do you want to tweak nginx configuration (enables gzip)? [Y|N]" -n 1 -r
else
  if [ "$4" == "nginx_tweak" ]; then
    REPLY="Y"
  fi
fi
if [[ $REPLY =~ ^[Yy]$ ]]; then
  grep "gzip_disable \"msie6\"" /etc/nginx/nginx.conf >>/dev/null || sed -i -e "s/gzip on;/gzip on;\n\tgzip_disable \"msie6\";/" /etc/nginx/nginx.conf
  sed -i "s/# gzip/gzip/" /etc/nginx/nginx.conf
fi

# Configure firewall
if [ -z "$1" ]; then
  read -p "Do you want to configure the firewall (opens 22, 80 and 443)? [Y|N]" -n 1 -r
else
  if [ "$4" == "firewall_conf" ]; then
    REPLY="Y"
  fi
fi
if [[ $REPLY =~ ^[Yy]$ ]]; then
  which ufw || apt install -y ufw
  ufw allow 'OpenSSH'
  ufw allow 'Nginx Full'
  ufw delete allow 'Nginx HTTP'
  echo "y" | ufw enable
fi

# Generate strong Diffie Hellman
if [ -z "$1" ]; then
  read -p "Do you want to generate a Diffie Hellman? [Y|N]" -n 1 -r
else
  if [ -n "$2" ] && [ "$2" == "dh" ]; then
    REPLY="Y"
  fi
fi
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "if it gets too long, you can cancel (Ctrl+c), and generate later with : ssl_dhparam"
  ssl_dhparam
else
  echo "You can still generate a Diffie Hellman later on by runnning : ssl_dhparam or ssl_dhparam my_dhparam.pem"
fi
