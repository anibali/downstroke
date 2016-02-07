#!/bin/bash -e

GITHUB_REPO="anibali/downstroke"

docker run --rm -v $PWD:/app -u "$UID:$GID" anibali/ldoc .
cd doc

git init
git remote add origin git@github.com:$GITHUB_REPO.git
git fetch origin gh-pages
git reset --mixed origin/gh-pages
git checkout -b gh-pages --track origin/gh-pages
git add .
git commit -m "Automatic documentation update [ci skip]"
git push origin gh-pages
rm -rf .git
