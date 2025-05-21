#!/bin/bash
BRANCH_NAME=$(echo "$CODEBUILD_WEBHOOK_HEAD_REF" | sed 's|refs/heads/||')
echo "Running logic for branch: $BRANCH_NAME"
if [[ "$BRANCH_NAME" == feature/* ]]; then
  echo "Merging feature branch into develop..."
  git checkout develop
  git merge origin/"$BRANCH_NAME" --no-ff -m "Auto-merge from $BRANCH_NAME"
  git push origin develop
fi
