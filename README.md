# nginx-opencart-setup



NGINX setup for OPENCART based on 
[DigitalOcean Recommendations](https://www.digitalocean.com/community/tools/nginx/) 

and on this [discussion](https://github.com/opencart/opencart.github.io/issues/335) ,

tested on Ubuntu 24.04


To install just run in terminal 
```shell
curl -s https://raw.githubusercontent.com/radiocab/nginx-opencart-setup/refs/heads/main/setup.sh \
| bash -s -- reallymydomain.site
```
with your own domain instead of reallymydomain.site of course

Besause Let's Encrypt allows no more than 50 certificates 
to be issued per registered domain per week, for testing 
you can try this script with "--dry-run" (then no real certificate will be issued).
 
The dry-run should succeed if 
- either the certificate already was once issued on your testing host,
- or your need to copy your issued certificate for your domain from your previuos host

As a hint for the second case: you can download certificate files from previuos host
(fullchain.pem, chain.pem and privkey.pem) and place them on one 
your secret [GIST](https://gist.github.com) on your github account.
Then you can run on followng command on your testing host terminal to transfer them 
to the host in test (obviously, you will have your own URL to your gist's ZIP) : 

```shell

# set your domain like:
# mydomain=reallymydomain.site

# set path to your secret gist's ZIP like:
# gistkeyszip=https://gist.github.com/your-github-acc/cf5csomefakeurlca5/archive/bc2morefakerurl9g.zip

if  [ -z ${mydomain+x} ] || [ "$mydomain" = "reallymydomain.site" ] ; then 
 printf "\n\nSet mydomain=reallymydomain.site first. Do nothing..\n\n"  
else   
 if [ ! -f /etc/letsencrypt/live/$mydomain/fullchain.pem ]; then 
   curl -Lo keys.zip $gistkeyszip
   mkdir -p  /etc/letsencrypt/live/$mydomain
   unzip keys.zip  -d ./keys
   find  ./keys -name "*.pem" -type f -exec cp {} /etc/letsencrypt/live/$mydomain/  \;
   rm -r ./keys
 else 
  printf "\n\nSome cert keys already exist. Do nothing not to damage\n\n" 
 fi
fi 

rm keys.zip
```

Not forget to change the 'A' record in DNS by your DNS- or NS- provider 
to your new IP address for testing host first.
 
After that you can try with "dry-run":
 
https://gist.github.com/radiocab/cf5csomefakeurlca5b173e94/archive/bcd255morefakerurl9fd.zip
For "dry-run" of the Letsencrypt bot run in terminal 
```shell
# set your domain like:
# mydomain=reallymydomain.site

curl -s https://raw.githubusercontent.com/radiocab/nginx-opencart-setup/refs/heads/main/setup.sh \
| bash -s -- $mydomain --dry-run
```

To install Opencart into so prepared environment use
```shell

# 1st arg - set your domain like:
# mydomain=reallymydomain.site

# 2nd arg -  release url (if omitted, then release 3.0.4.0 will be installed):
releaseurl='https://github.com/opencart/opencart/releases/download/3.0.3.2/opencart-3.0.3.2.zip'

# 3rd arg - root in (custom) release zip (standart 'upload' assumed):
# releaseroot='upload-3040'

curl -s https://raw.githubusercontent.com/radiocab/nginx-opencart-setup/refs/heads/main/install-opencart.sh \
| bash -s -- $mydomain $releaseurl $releaseroot

```

If you preparing LEMP setup from scratch for new server 
(on cloud you can even try this as cloud-init script ), 
you can use for the whole setup

 - in dry-run case:
```shell
#!/bin/sh


# set your domain like:
# mydomain=reallymydomain.site

# set path to your secret gist's ZIP like:
gistkeyszip=https://gist.github.com/radiocab/cf5c96361b78171b741bc0ca5b173e94/archive/bcd255612af9a4acf27962d33dbc3ad73f5cf9fd.zip

if  [ -z ${mydomain+x} ] || [ "$mydomain" = "reallymydomain.site" ] ; then 
 printf "\n\nSet mydomain="reallymydomain.site" first. Do nothing..\n\n"  
else   
 if [ ! -f /etc/letsencrypt/live/$mydomain/fullchain.pem ]; then 
   curl -Lo keys.zip $gistkeyszip
   mkdir -p  /etc/letsencrypt/live/$mydomain
   sudo apt-get install unzip
   unzip keys.zip  -d ./keys
   find  ./keys -name "*.pem" -type f -exec cp {} /etc/letsencrypt/live/$mydomain/  \;
   rm -r ./keys
 else 
  printf "\n\nSome cert keys already exist. Do nothing not to damage\n\n" 
 fi
fi 

curl https://raw.githubusercontent.com/radiocab/nginx-opencart-setup/refs/heads/main/install-lemp.sh \
| bash -s -- $mydomain --dry-run

```

- in real issuing of Let's Encrypt certificate:
```shell
#!/bin/sh

# set your domain like:
# mydomain=reallymydomain.site
if  [ -z ${mydomain+x} ] || [ "$mydomain" = "reallymydomain.site" ] ; then 
 printf "\n\nSet mydomain="reallymydomain.site" first. Do nothing..\n\n"  
else 
 curl https://raw.githubusercontent.com/radiocab/nginx-opencart-setup/refs/heads/main/install-lemp.sh \
  | bash -s -- $mydomain  
fi 

```


See also starting point for all this on [DigitalOcean configuration](https://www.digitalocean.com/community/tools/nginx?global.security.securityTxt=true&global.logging.errorLogEnabled=true&global.logging.logNotFound=true)
