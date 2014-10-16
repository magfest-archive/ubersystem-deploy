
run this on a node to see the value for "uber_instances" as interpreted by hiera
```
# for YOURSERVERNAMEHERE.com
hiera --config /usr/local/puppet/hiera/hiera.yaml -d -h uber_instances ::fqdn=YOUR.SERVER.HOSTNAME.COM

# for vagrant
hiera --config /usr/local/puppet/hiera/hiera.yaml -d -h uber_instances ::fqdn=localhost ::is_vagrant=1

# for looking up which classes a node should have
hiera --config /usr/local/puppet/hiera/hiera.yaml -d -a classes ::fqdn=localhost ::is_vagrant=1
```
