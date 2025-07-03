#!/bin/bash

# Get the current remote URL
REMOTE_URL=$(git config --get remote.origin.url)

if [ -z "$REMOTE_URL" ]; then
  echo "No remote URL found. Please set up your remote first."
  exit 1
fi

# Set the fetch configuration
git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"

echo "Git configuration updated for this project."
echo "Remote URL: $REMOTE_URL"
echo "Fetch configuration: +refs/heads/*:refs/remotes/origin/*"
