
run this on a node to see the value for "uber_instances" as interpreted by hiera
```
hiera --config /usr/local/puppet/hiera/hiera.yaml -d -h uber_instances ::fqdn=YOUR.SERVER.HOSTNAME.COM
```
