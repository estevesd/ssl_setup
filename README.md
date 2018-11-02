# SSL setup
Getting A+ 100% rating on SSLlabs test with nginx and letsencrypt
Tested on Ubuntu 18.04
nginx >= 1.5.9
letsecncrypt >= 0.25

Meant to be ran on a fresh server.
It will install/configure nginx and letsencrypt
Use with caution if you already have nginx installed and configured.
`/etc/nginx/sites-{available,enabled}/default` will be deleted.
`/etc/nginx/sites-{available,enabled}/example.com` will be created.

## DNS setup
DNS records for example.com and www.example.com should already exist.
It'll attempt to set a redirection from www.example.com to example.com, if there's no record for www.example.com it'll only do the setup for example.com

### CAA
To get a 100% rating a CAA record is needed.
This is not necessary to do the setup and can be done later on.

## Installation
### Get the code
```shell
git clone https://github.com/estevesd/ssl_setup.git ~/ssl_setup
```

### Interactive Installation
# specifying an email is necessary to register on letsencrypt. if nothing is specified here letsencrypt registration will ask for it anyway.
```
bash ~/ssl_setup/install.sh
```
### Unattended Installation
`bash ~/ssl_setup/install.sh email@example.com [dh|no_dh] [nginx_tweak|no_nginx_tweak] [firewall_conf|no_firewall_conf]`
1. An email is necessary to register on letsencrypt.
2. `dh` or `no_dh` to generate a strong Diffie Hellman key or not (necessary to get 100% on Key Exchange)
3. `nginx_tweak` or `no_nginx_tweak` to tweak nginx configuration or not (enables gzip)
4. `firewall_conf` or `no_firewall_conf` to open ports using `ufw` (opens 22, 80 and 443)

## Usage
`ssl_setup [domain] [path to root](optional, default:/var/www/[domain])`
This will create nginx configuration and SSL certificates.

## DH parameters
Generating a 4096bits needed to get a 100% rating on Key exchange can take a very long time. So it's optional during installation.
To generate it later on, run 'ssl_dhparam'
Since it can take a very long time to generate a key, you can do it an another machine :
`openssl dhparam -out my_dhparams.pem 4096`
and then run
`ssl_dhparam my_dhparams.pem`

## Renewal
A cronjob will be added to check/renew certificates periodically
`ssl_renew`

## Test
https://www.ssllabs.com/ssltest/analyze.html?d=example.com&latest=yes
