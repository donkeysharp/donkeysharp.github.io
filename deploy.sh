#!/bin/bash

function sync_master() {
  pushd public
  git pull origin master
  popd
}

function build_site() {
  sync_master

  # Build the project
  hugo -t beautifulhugo

  pushd public
  git add .

  msg="rebuilding site `date`"
  if [ $# -eq 1 ]
    then msg="$1"
  fi
  git commit -m "$msg"

  git push origin master

  popd
}

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"
build_site
