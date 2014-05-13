#!/bin/bash

# TODO: make this take arguments

# apply config settings to remote host
fab -u root -H staging.magfest.net apply
