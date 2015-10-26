#!/bin/bash

# Bash shell script for generating self-signed certs. Run this in a folder, as it
# generates a few files. Large portions of this script were taken from the
# following artcile:
# 
# http://usrportage.de/archives/919-Batch-generating-SSL-certificates.html
# 
# Additional alterations by: Brad Landers
# Date: 2012-01-27

# Script accepts a single argument, the fqdn for the cert
#DOMAIN="$1"

DOMAIN="apache"

if [[ ! -f /etc/apache2/ssl/$DOMAIN.key || ! -f /etc/apache2/ssl/$DOMAIN.crt ]]; then
  echo "*** SSL Certificates missing from /etc/apache2/ssl. Creating them ..."

  mkdir -p /etc/apache2/ssl
  cd /etc/apache2/ssl

  rm -f /etc/apache2/ssl/$DOMAIN.*

  if [ -z "$DOMAIN" ]; then
    echo "Usage: $(basename $0) <domain>"
    exit 11
  fi

  fail_if_error() {
    [ $1 != 0 ] && {
      unset PASSPHRASE
      exit 10
    }
  }

  # Generate a passphrase
  export PASSPHRASE=$(head -c 500 /dev/urandom | tr -dc a-z0-9A-Z | head -c 128; echo)

  # Certificate details; replace items in angle brackets with your own info
  subj="/O=$DOMAIN"

  # Generate the server private key
  openssl genrsa -des3 -out $DOMAIN.key -passout env:PASSPHRASE 2048
  fail_if_error $?

  # Generate the CSR
  openssl req \
      -new \
      -batch \
      -subj "$(echo -n "$subj" | tr "\n" "/")" \
      -key $DOMAIN.key \
      -out $DOMAIN.csr \
      -passin env:PASSPHRASE
  fail_if_error $?
  cp $DOMAIN.key $DOMAIN.key.org
  fail_if_error $?

  # Strip the password so we don't have to type it every time we restart Apache
  openssl rsa -in $DOMAIN.key.org -out $DOMAIN.key -passin env:PASSPHRASE
  fail_if_error $?

  # Generate the cert (good for 10 years)
  openssl x509 -req -days 3650 -in $DOMAIN.csr -signkey $DOMAIN.key -out $DOMAIN.crt
  fail_if_error $?

  chmod 400 /etc/apache2/ssl/$DOMAIN.key
else
  echo "SSL Certificate are available in /etc/apache2/ssl."
fi