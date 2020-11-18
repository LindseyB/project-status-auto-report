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
REPORT="$(ruby /generate-report.rb)"

export GITHUB_USER="$GITHUB_ACTOR"

git config --global user.name $GIT_USER_NAME
git config --global user.email $GIT_EMAIL

COMMAND="hub issue create -m $REPORT -l status"

echo "$COMMAND"
sh -c "$COMMAND"
