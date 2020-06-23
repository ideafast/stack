#!/bin/sh
cd docs/
bundle install
bundle exec jekyll build
cd ../
