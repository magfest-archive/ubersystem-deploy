
run this on a node to see the values as interpreted by hiera
```
hiera --config /usr/local/puppet/hiera/hiera.yaml uber::nginx::hostname

# older stuff below

# for YOURSERVERNAMEHERE.com
hiera --config /usr/local/puppet/hiera/hiera.yaml -d -h uber_instances ::fqdn=YOUR.SERVER.HOSTNAME.COM

# for vagrant
hiera --config /usr/local/puppet/hiera/hiera.yaml -d -h uber_instances ::fqdn=localhost ::is_vagrant=1

# for looking up which classes a node should have
hiera --config /usr/local/puppet/hiera/hiera.yaml -d -a classes ::fqdn=localhost ::is_vagrant=1
```
