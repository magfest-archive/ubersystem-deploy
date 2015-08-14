#!/bin/bash
# dump config from a remote box, filter out some stuff, and save it to a file

ssh root@$1 /usr/local/uber/env/bin/sep print_config \
        | grep -v tools.proxy.base \
        | grep -v sqlalchemy \
        | grep -v hostname \
        | grep -v url_base \
        | grep -v url_root \
       > $1.cfg

#        | grep -v aws_access_key \
#        | grep -v aws_secret_key \
#        | grep -v stripe_public_key \
#        | grep -v stripe_secret_key \
 
