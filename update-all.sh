#!/bin/bash
set -e

git pull

pushd puppet/modules/uber
git pull
popd

pushd puppet/hiera/nodes
git pull
popd
