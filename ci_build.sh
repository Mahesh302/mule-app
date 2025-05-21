#!/bin/bash
set -e

# Clone repo if not present
if [ ! -d mule-app ]; then
  echo "Cloning mule-app repo..."
  git clone https://github.com/Mahesh302/mule-app.git
else
  echo "mule-app directory exists. Skipping clone."
fi

cd mule-app

# Now you can add your branch logic or build commands here
# For example:
if [ -n "$CODEBUILD_WEBHOOK_HEAD_REF" ]; then
  BRANCH_NAME=$(echo "$CODEBUILD_WEBHOOK_HEAD_REF" | sed 's|refs/heads/||')
else
  BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
fi

echo "Current branch: $BRANCH_NAME"

# Add branch-based logic here ...
