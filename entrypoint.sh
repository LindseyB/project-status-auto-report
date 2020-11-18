#!/bin/bash -l

set -e

if [[ -z "$GITHUB_TOKEN" ]]; then
  echo "Required the GITHUB_TOKEN environment variable."
  exit 1
fi

if [[ -z "$PROJECT_ID" ]]; then
    echo "require to set with: PROJECT_ID."
  exit 1
fi

if [[ -z "$REPO_OWNER" ]]; then
  echo "require to set with: REPO_OWNER."
  exit 1
fi

if [[ -z "$REPO_NAME" ]]; then
  echo "require to set with: REPO_NAME."
  exit 1
fi


gem install json --no-document
ruby /generate-report.rb
