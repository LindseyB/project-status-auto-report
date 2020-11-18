#!/bin/bash -l

set -e

if [[ -z "$GITHUB_TOKEN" ]]; then
  echo "Required the GITHUB_TOKEN environment variable."
  exit 1
fi

if [[ -z "$GIT_USER_NAME" ]]; then
    echo "require to set with: GIT_USER_NAME."
  exit 1
fi

if [[ -z "$GIT_EMAIL" ]]; then
  echo "require to set with: GIT_EMAIL."
  exit 1
fi

git remote set-url origin "https://$GITHUB_ACTOR:$GITHUB_TOKEN@github.com/$GITHUB_REPOSITORY"
git checkout master

gem install json --no-document
ruby /generate-report.rb
