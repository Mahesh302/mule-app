#!/bin/bash
set -e  # Stop script if any command fails

env | grep CODEBUILD

if [ -n "$CODEBUILD_WEBHOOK_HEAD_REF" ]; then
  BRANCH_NAME=$(echo "$CODEBUILD_WEBHOOK_HEAD_REF" | sed 's|refs/heads/||')
else
  BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
fi

echo "Running logic for branch: $BRANCH_NAME"

if [[ "$BRANCH_NAME" == feature/* ]]; then
  echo "Merging feature branch '$BRANCH_NAME' into develop..."

  git fetch origin || { echo "git fetch failed"; exit 1; }
  git checkout develop || { echo "git checkout develop failed"; exit 1; }
  git merge origin/"$BRANCH_NAME" --no-ff -m "Auto-merge from $BRANCH_NAME" || { echo "git merge failed"; exit 1; }
  git push origin develop || { echo "git push failed"; exit 1; }

  echo "Merge completed successfully."
else
  echo "Branch is not a feature branch. Skipping merge."
fi
