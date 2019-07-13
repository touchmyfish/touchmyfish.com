#!/bin/bash

git config --global user.email "travis@travis-ci.org"
git config --global user.name "Travis CI"
git checkout --orphan gh-pages
shopt -s extglob
rm -rf !(_site) && mv _site/* . && rm -rf _site
touch .nojekyll
git config credential.helper "store --file=.git/credentials"
echo "https://${GH_TOKEN}:@github.com" > .git/credentials
echo "touchmyfish.com" > CNAME
git add .
git commit --message "Travis build: $TRAVIS_BUILD_NUMBER"
git push origin gh-pages -f
