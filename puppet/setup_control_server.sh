#!/bin/bash

sudo apt-get update -y
sudo apt-get install fabric vim lynx git tofrodos

sudo fab -u root -H localhost bootstrap_control_server