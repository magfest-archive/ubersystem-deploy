2018 example for maglabs 2018 production:
```
hiera --config hiera/hiera.yaml uber::config::hide_schedule ::fqdn=labs2018.uber.magfest.org ::event_name=labs ::environment=production ::event_year=2018
```

older examples below

run this on a node to see the values as interpreted by hiera
```
hiera --config hiera.yaml uber::config::post_con ::fqdn=prime.uber.magfest.org ::event_name=prime ::environment=production

hiera --config /usr/local/puppet/hiera/hiera.yaml uber::nginx::hostname

# older stuff below

# for YOURSERVERNAMEHERE.com
hiera --config /usr/local/puppet/hiera/hiera.yaml -d -h uber_instances ::fqdn=YOUR.SERVER.HOSTNAME.COM

# for vagrant
hiera --config /usr/local/puppet/hiera/hiera.yaml -d -h uber_instances ::fqdn=localhost ::is_vagrant=1

# for looking up which classes a node should have
hiera --config /usr/local/puppet/hiera/hiera.yaml -d -a classes ::fqdn=localhost ::is_vagrant=1
```

to access python stuff from the commandline for testing or batch operations:
```
. /usr/local/uber/env/bin/activate
python3
import sideboard
from uber.common import * 
session = Session().session
```
