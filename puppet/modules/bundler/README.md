# Bundler Module

This module automatically install ruby dependencies using Bundler.

## Dependencies

- The [`ruby` module](https://github.com/puppetlabs/puppetlabs-ruby) has to be installed alongside this module.

## Examples

Deploy a bundle with something like the following.

    bundler::install { $app_root:
      user       => $app_user,
      group      => $app_group,
      deployment => true,
      without    => 'development test doc',
    }

