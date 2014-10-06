#!/bin/bash

sudo apt-get update -y
sudo apt-get install fabric vim lynx git tofrodos

fab -u root -H `hostname` bootstrap_vagrant_control_server