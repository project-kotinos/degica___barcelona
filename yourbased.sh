#!/usr/bin/env bash
set -ex
gem update --system
gem install bundler -v 2.0.1
# install
bundle install --jobs=3 --retry=3
# before_script
npm install -g barcelona
which node
gem install bcnd
#psql -c 'create database travis_ci_test;' -U postgres
# script
set -e
#psql -c 'drop database travis_ci_test;' 
#psql -c 'create database travis_ci_test;'
RAILS_ENV=test bundle exec rake db:drop
RAILS_ENV=test bundle exec rake db:create
bundle exec rake db:setup spec
bcnd
