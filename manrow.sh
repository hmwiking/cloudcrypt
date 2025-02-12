#!/bin/bash

encFileName="$(openssl rand -base64 12 | tr -dc 'A-Za-z0-9' | head -c 32).gpg"
printf "%s;%s;%s\n" "${encFileName}" "$(basename "${1}")" "$(md5sum "${1}" | awk '{ print $1 }')"

exit 0
