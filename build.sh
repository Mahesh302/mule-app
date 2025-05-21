#!/bin/bash

BRANCH_NAME=$1
echo "Running logic for branch: $BRANCH_NAME"

if [[ "$BRANCH_NAME" == feature/* ]]; then
  echo "Merging feature into develop"
  git checkout develop
  git merge origin/"$BRANCH_NAME" --no-ff --allow-unrelated-histories -m "Auto-merge from $BRANCH_NAME"
  git push origin develop
elif [[ "$BRANCH_NAME" == "develop" ]]; then
  echo "Building project and merging develop into release"
  mvn clean package -DskipTests
  git checkout release
  git merge origin/develop --no-ff --allow-unrelated-histories -m "Auto-merge from develop"
  git push origin release
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