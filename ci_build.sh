#!/bin/bash
set -e

echo "Checking git repository..."
if [ ! -d .git ]; then
  echo "Error: Not a git repository. Exiting."
  exit 1
fi

if [ -n "$CODEBUILD_WEBHOOK_HEAD_REF" ]; then
  BRANCH_NAME=$(echo "$CODEBUILD_WEBHOOK_HEAD_REF" | sed 's|refs/heads/||')
else
  BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
fi

echo "Detected branch: $BRANCH_NAME"

chmod +x build.sh
./build.sh "$BRANCH_NAME"
