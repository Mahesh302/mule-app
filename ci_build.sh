#!/bin/bash

# Extract branch name from webhook reference
BRANCH_NAME=$(echo "$CODEBUILD_WEBHOOK_HEAD_REF" | sed 's|refs/heads/||')
echo "Running logic for branch: $BRANCH_NAME"

if [[ "$BRANCH_NAME" == feature/* ]]; then
  echo "Merging feature branch '$BRANCH_NAME' into develop..."

  git fetch origin

  # Checkout develop branch
  git checkout develop

  # Merge the remote feature branch into develop
  git merge origin/"$BRANCH_NAME" --no-ff -m "Auto-merge from $BRANCH_NAME"

  # Push the changes to develop branch on origin
  git push origin develop
else
  echo "Branch is not a feature branch. Skipping merge."
fi
