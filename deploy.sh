#!/bin/bash
git stash
bundle exec jekyll build
git branch -D gh-pages
git checkout --orphan gh-pages
shopt -s extglob
rm -rf !(_site) && mv _site/* . && rm -rf _site
ls -la
touch .nojekyll
echo "touchmyfish.com" > CNAME
rm -rf .gitignore
git add .
git commit --message "Manual Build"
git push origin gh-pages -f
git checkout master
git stash pop


