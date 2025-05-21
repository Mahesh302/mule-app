# #!/bin/bash
# set -e

# env | grep CODEBUILD

# if [ ! -d .git ]; then
#   echo "Error: Not a git repository. Exiting."
#   exit 1
# fi

# echo "Git info:"
# git status
# git branch -a
# git remote -v

# if [ -n "$CODEBUILD_WEBHOOK_HEAD_REF" ]; then
#   BRANCH_NAME=$(echo "$CODEBUILD_WEBHOOK_HEAD_REF" | sed 's|refs/heads/||')
# else
#   BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
# fi

# echo "Running logic for branch: $BRANCH_NAME"

# if [[ "$BRANCH_NAME" == feature/* ]]; then
#   echo "Merging feature branch '$BRANCH_NAME' into develop..."

#   git fetch origin develop || { echo "git fetch failed"; exit 1; }
#   git checkout develop || { echo "git checkout develop failed"; exit 1; }
#   git reset --hard origin/develop || { echo "git reset failed"; exit 1; }
#   git merge origin/"$BRANCH_NAME" --no-ff -m "Auto-merge from $BRANCH_NAME" || { echo "git merge failed"; exit 1; }
#   git push origin develop || { echo "git push failed"; exit 1; }

#   echo "Merge completed successfully."
# else
#   echo "Branch is not a feature branch. Skipping merge."
# fi



#!/bin/bash
set -e

# Clone your GitHub repo into a folder named 'mule-app'
git clone https://github.com/Mahesh302/mule-app.git

# Change directory into the cloned repo
cd mule-app

# Now you can safely run your git commands and build steps
# Example:
git fetch origin develop

# Your other build steps below
# ...


