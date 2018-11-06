# SSL setup
Setting up SSL with nginx and letsencrypt
![SSL labs - A+ - 100%](https://raw.githubusercontent.com/estevesd/ssl_setup/master/ssllabs.png)
Tested on Ubuntu 18.04
nginx >= 1.5.9  
letsecncrypt >= 0.25  

It will install/configure nginx and letsencrypt.  
Use with caution if you already have nginx installed and configured.  

On a fresh install this will also generate nginx configuration and a root directory.

Getting A+ and 100% everywhere is nice but not really realistic since it'll break on older clients.
However if it's not your concern, then this script will help you reach that goal.

If you need more compatibility then this script can help too (bye bye 100% or even A+)

## DNS setup
DNS records for example.com and www.example.com should already exist.  
It'll attempt to set a redirection from www.example.com to example.com, if there's no record for www.example.com it'll only do the setup for example.com

### CAA
A CAA record is needed to get the best rating possible.

## Installation
### Get the code
```shell
git clone https://github.com/estevesd/ssl_setup.git ~/ssl_setup
```

### Interactive Installation
```
bash ~/ssl_setup/install.sh
```
### Unattended Installation
`bash ~/ssl_setup/install.sh email@example.com [nginx_tweak|no_nginx_tweak] [firewall_conf|no_firewall_conf]`

1. An email is necessary to register on letsencrypt.
2. `nginx_tweak` or `no_nginx_tweak` to tweak nginx configuration or not (enables gzip)
2. `firewall_conf` or `no_firewall_conf` to open ports using `ufw` or not (opens 22, 80 and 443)

## Generate nginx configuration and SSL certificates
`ssl_setup [example.com] [old|intermediate|modern|strict](default: modern)`  
This will create nginx configuration and SSL certificates.
Strength is based on [Mozilla SSL Configuration Generator](https://mozilla.github.io/server-side-tls/ssl-config-generator/).  
Oldest compatible clients for :

- old : Windows XP IE6, Java 6
- intermediate : Firefox 1, Chrome 1, IE 7, Opera 5, Safari 1, Windows XP IE8, Android 2.3, Java 7
- modern : Firefox 27, Chrome 30, IE 11 on Windows 7, Edge, Opera 17, Safari 9, Android 5.0, and Java 8
- strict : same as modern, but even more strict. Needed to get A+ and 100% everywhere

## DHE parameters
As stated on [Mozilla's Server Side TLS Guidelines ](https://wiki.mozilla.org/Security/Server_Side_TLS#Pre-defined_DHE_groups) :
"Instead of using pre-configured DH groups, or generating their own with "openssl dhparam", operators should use the pre-defined DH groups ffdhe2048, ffdhe3072 or ffdhe4096 recommended by the IETF in [RFC 7919 https://tools.ietf.org/html/rfc7919]. These groups are audited and may be more resistant to attacks than ones randomly generated.  
Note: if you must support old Java clients, Dh groups larger than 1024 bits may block connectivity (see #DHE_and_Java)."

By default ffdhe2048 or ffdhe4096 will be used depending on expected compatibility.

### Change key strength
`ssl_dhparam [example.com] [1024|2048|3072|4096|6144|8192]`

### Generating your own key
`ssl_dhparam [example.com] [1024|2048|3072|4096|6144|8192] 1`

Since it can take a very long time, you can do it an another machine :  
`openssl dhparam -out my_dhparams.pem 4096`  
and then run  
`ssl_dhparam [example.com] my_dhparams.pem`

## Renewal
A cronjob or systemd timer will be added to check/renew certificates periodically, however it can be done manually.  
`ssl_renew`  
or even forced  
`ssl_renew force`

## Test
https://www.ssllabs.com/ssltest/analyze.html?d=example.com&latest=yes

## Sources/Inspiration
- [Mozilla's Server Side TLS Guidelines ](https://wiki.mozilla.org/Security/Server_Side_TLS)
- [Mozilla SSL Configuration Generator](https://mozilla.github.io/server-side-tls/ssl-config-generator/)
- [cipherli.st](https://cipherli.st/)
- [Getting an A+ rating on the Qualys SSL Test](https://scotthelme.co.uk/a-plus-rating-qualys-ssl-test/)
- [How to secure nginx with let's encrypt on Ubuntu 18.04](https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-18-04)
