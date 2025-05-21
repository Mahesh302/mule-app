#!/bin/bash
set -e

BRANCH_NAME=$1
echo "Running build logic for branch: $BRANCH_NAME"

# Always fetch latest updates
git fetch origin

if [[ "$BRANCH_NAME" == feature/* ]]; then
  echo "Merging feature branch '$BRANCH_NAME' into develop..."
  git checkout develop
  git reset --hard origin/develop
  git merge origin/"$BRANCH_NAME" --no-ff -m "Auto-merge from $BRANCH_NAME"
  git push origin develop

elif [[ "$BRANCH_NAME" == "develop" ]]; then
  echo "Building project with Maven (skip tests)..."
  mvn clean package -DskipTests

  echo "Merging develop into release branch..."
  git checkout release
  git reset --hard origin/release
  git merge origin/develop --no-ff -m "Auto-merge from develop"
  git push origin release

elif [[ "$BRANCH_NAME" == release* ]]; then
  echo "Creating snapshot zip and uploading to S3..."
  mkdir -p snapshots
  SNAPSHOT_NAME="snapshot-$(date +%Y%m%d-%H%M%S).zip"
  zip -r "snapshots/$SNAPSHOT_NAME" .

  echo "Uploading snapshot $SNAPSHOT_NAME to S3 bucket..."
  aws s3 cp "snapshots/$SNAPSHOT_NAME" s3://mule-snapshot/"$SNAPSHOT_NAME"

elif [[ "$BRANCH_NAME" == "main" ]]; then
  echo "Running Postman tests with Newman..."
  newman run postman_collection.json --reporters cli,html --reporter-html-export newman-report.html

  echo "Uploading Newman report to S3 bucket..."
  aws s3 cp newman-report.html s3://postman-report-bucket/newman-report-$(date +%Y%m%d-%H%M%S).html

else
  echo "No matching branch rules. Skipping build steps."
fi
