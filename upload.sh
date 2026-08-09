#!/bin/bash
set -e

# Fetch remote updates
echo "Fetching remote updates..."
git fetch origin

# Check if local and remote are in sync
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)
if [ "$LOCAL" != "$REMOTE" ]; then
    echo "Local and remote are out of sync. Attempting rebase..."
    git rebase origin/main || {
        echo "Rebase conflict detected! Please resolve manually."
        exit 1
    }
fi

# Add only newly created files (ignore modifications/deletions)
NEW_FILES=$(git ls-files --others --exclude-standard)
if [ -n "$NEW_FILES" ]; then
    echo "$NEW_FILES" | xargs git add
else
    echo "No new files to add. Exiting."
    exit 0
fi

# Commit with timestamp
git commit -m "Auto-add new files on $(date '+%Y-%m-%d %H:%M:%S')"

# Push to remote
git push origin main
echo "Push successful!"