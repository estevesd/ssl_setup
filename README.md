# SSL setup
Getting A+ 100% rating on SSLlabs test with nginx and letsencrypt
Tested on Ubuntu 18.04
nginx >= 1.5.9
letsecncrypt >= 0.25

Meant to be ran on a fresh server

## Installation
```shell
cd ~/
git clone https://github.com/estevesd/ssl_setup.git .
cd $_
bash install.sh email@example.com
```

## Usage
`ssl_setup [domain] [path to root](optional, default:/var/www/[domain])`
```shell
ssl_setup example.com /var/http
```

## DH parameters
Generating a 4096bits needed to get a 100% rating on Key exchange can take a very long time. So it's optional during installation.
To generate it later on, run 'ssl_dhparam'

## Renewal
A cronjob will be added to check/renew certificates periodically
`ssl_renew`
