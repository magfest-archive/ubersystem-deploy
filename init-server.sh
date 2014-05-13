#!/bin/bash

# TODO: make this take arguments

# this script inits a server with Fabric and sticks a puppet config on it
# which can then be used to do stuff. only run this script once, and once
# it's successful, use apply instead

fab -u root -H staging.magfest.net setup_client apply
