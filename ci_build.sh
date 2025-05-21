#!/bin/bash
set -e

# Check if GITHUB_TOKEN is set
if [ -z "$GITHUB_TOKEN" ]; then
  echo "Error: GITHUB_TOKEN environment variable is not set."
  exit 1
fi

# Clone repo if not present
if [ ! -d mule-app ]; then
  echo "Cloning mule-app repo..."
  git clone https://$GITHUB_TOKEN@github.com/Mahesh302/mule-app.git
else
  echo "mule-app directory exists. Skipping clone."
fi

cd mule-app

# Configure git user info (for commits)
git config --global user.email "build@codebuild.aws"
git config --global user.name "AWS CodeBuild"

# Detect branch name
if [ -n "$CODEBUILD_WEBHOOK_HEAD_REF" ]; then
  BRANCH_NAME=$(echo "$CODEBUILD_WEBHOOK_HEAD_REF" | sed 's|refs/heads/||')
else
  BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
fi

echo "Current branch: $BRANCH_NAME"

# Fetch latest remote branches and tags
git fetch origin

# Branch-based logic
if [[ "$BRANCH_NAME" == feature/* ]]; then
  echo "Merging feature into develop"
  git checkout develop
  git pull origin develop
  git merge origin/"$BRANCH_NAME" --no-ff --allow-unrelated-histories -m "Auto-merge from $BRANCH_NAME"
  git push https://$GITHUB_TOKEN@github.com/Mahesh302/mule-app.git develop

elif [[ "$BRANCH_NAME" == "develop" ]]; then
  echo "Building project and merging develop into release"
  mvn clean package -DskipTests
  git checkout release
  git pull origin release
  git merge origin/develop --no-ff --allow-unrelated-histories -m "Auto-merge from develop"
  git push https://$GITHUB_TOKEN@github.com/Mahesh302/mule-app.git release

elif [[ "$BRANCH_NAME" == release* ]]; then
  echo "Creating snapshot zip and uploading to S3"
  mkdir -p snapshots
  SNAPSHOT_NAME="snapshot-$(date +%Y%m%d-%H%M%S).zip"
  zip -r "snapshots/$SNAPSHOT_NAME" .
  aws s3 cp "snapshots/$SNAPSHOT_NAME" s3://mule-snapshot/"$SNAPSHOT_NAME"

elif [[ "$BRANCH_NAME" == "main" ]]; then
  echo "Running Postman tests"
  newman run postman_collection.json --reporters cli,html --reporter-html-export newman-report.html
  aws s3 cp newman-report.html s3://postman-report-bucket/newman-report-$(date +%Y%m%d-%H%M%S).html

else
  echo "No matching branch rule. Skipping build"
fi
