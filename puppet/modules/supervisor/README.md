# puppet-supervisor

This puppet module automates installation/management of supervisord and programs that it will control.

NOTE: This will install supervisord v3.0 + [superlance](https://github.com/Supervisor/superlance/blob/master/docs/index.rst) plugins. There are no RPM packages, as of the time of writing, for the supervisord 3.x so this modulle installs it using `easy_install`

Tested on CentOS 6.4, Ubuntu 12.04 and AWS Linux.

## Versioning

This module adheres to [Semantic Versioning 2.0.0-rc.2](http://semver.org/).

## TODOs
  * eventlisteners

## Parameters

See supervisord manual on list of valid values [here](http://supervisord.org/configuration.html#program-x-section-settings).

## Usage
<pre>
supervisor::program { 'node-app':
  ensure      => present,
  enable      => true,
  command     => '/usr/bin/node /home/ec2-user/modules/app.js',
  directory   => '/home/ec2-user/modules/',
  environment => 'NODE_ENV=testing',
  user        => 'ec2-user',
  group       => 'ec2-user',
  logdir_mode => '0770',
}
</pre>
## Dependencies

None

## Inspiration

This module was inspired by this [work](https://github.com/plathrop/puppet-module-supervisor). It doesn't support CentOS and AWS Linux so I had to modify it a bit.
