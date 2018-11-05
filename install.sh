#!/usr/bin/env bash
if [ "$(id -u)" != "0" ]; then
  echo "This command must be run as root" 1>&2
  exit 1
fi

SRC_PATH=$(dirname "$0")
SRC_PATH=$( (cd "$SRC_PATH" && pwd))
if [ -z "$SRC_PATH" ]; then
  echo "No access to source directory"
  exit 1 # fail
fi

cp $SRC_PATH/ssl_{setup,renew,dhparam} /usr/local/bin
chmod 755 /usr/local/bin/ssl_{setup,renew,dhparam}
cp -r $SRC_PATH/var /

add-apt-repository --yes --no-update ppa:certbot/certbot
apt update
apt install -y python-certbot-nginx nginx haveged

## configure letsencrypt
if [ -z "$1" ]; then
  letsencrypt register --agree-tos --no-eff-email
else
  letsencrypt register --non-interactive --no-eff-email --agree-tos -m $1
fi
cat >>/etc/letsencrypt/cli.ini <<EOF

# Use a 4096 bit RSA key instead of 2048
rsa-key-size = 4096

# reload nginx after certificates renewal
post-hook = systemctl reload nginx
EOF
[ -f /etc/letsencrypt/options-ssl-nginx.conf.bkp ] || cp /etc/letsencrypt/options-ssl-nginx.conf /etc/letsencrypt/options-ssl-nginx.conf.bkp
cp /var/lib/ssl_setup/options-ssl-nginx.conf /etc/letsencrypt/options-ssl-nginx.conf
##

## enable gzip in nginx
if [ -z "$1" ]; then
  read -p "Do you want to tweak nginx configuration (enables gzip)? [y|n]" -n 1 -r
  echo ""
else
  if [ "$4" == "nginx_tweak" ]; then
    REPLY="Y"
  fi
fi
if [[ $REPLY =~ ^[Yy]$ ]]; then
  grep "gzip_disable \"msie6\"" /etc/nginx/nginx.conf >>/dev/null || sed -i -e "s/gzip on;/gzip on;\n\tgzip_disable \"msie6\";/" /etc/nginx/nginx.conf
  sed -i "s/# gzip/gzip/" /etc/nginx/nginx.conf
fi
##

## Configure firewall
if [ -z "$1" ]; then
  read -p "Do you want to configure the firewall (opens 22, 80 and 443)? [y|n]" -n 1 -r
  echo ""
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
##

## Generate strong Diffie Hellman
if [ -z "$1" ]; then
  read -p "Do you want to generate a Diffie Hellman? [y|n]" -n 1 -r
  echo ""
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
##

## INSTALLATION DONE
echo "Installation done : run $(ssl_setup domain.example.com) to create your certificates and nginx configuration"
