ssh root@$1 /usr/local/uber13/env/bin/sep print_config \
        | grep -v tools.proxy.base \
        | grep -v sqlalchemy \
        | grep -v hostname \
        | grep -v url_base \
        | grep -v url_root \
        | grep -v aws_access_key \
        | grep -v aws_secret_key \
        | grep -v stripe_public_key \
        | grep -v stripe_secret_key \
        > $1.cfg
