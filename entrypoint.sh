#!/bin/bash
set -e

OUTPUT_FILE="Wiki-Files/Current-Workflows.md"
REPO_DIR=$(mktemp -d)

echo "Cloning repository $REPO..."
git clone "https://$GITHUB_TOKEN@github.com/$REPO.git" "$REPO_DIR"
cd "$REPO_DIR"

echo "Generating Current-Workflows list..."
echo -e "# Current-Workflows\n" > "$OUTPUT_FILE"
find Workflows/* -type f -name "README.md" | while read README_FILE; do
    NAME=$(grep '^# ' "$README_FILE" | head -n 1 | sed 's/^# //')
    DESCRIPTION=$(awk '
      BEGIN {flag=0}
      /^## / {flag=1; next}
      /^#/ {flag=0}
      flag && !/^$/ {print; exit}
    ' "$README_FILE")
    if [ -n "$NAME" ] && [ -n "$DESCRIPTION" ]; then
        echo -e "- **$NAME**: $DESCRIPTION" >> "$OUTPUT_FILE"
    fi
done

echo "Committing changes..."
git config user.email "github-actions[bot]@users.noreply.github.com"
git config user.name "github-actions[bot]"
git add "$OUTPUT_FILE"
git commit -m "Update Current-Workflows.md with latest workflow information" || echo "No changes to commit"
git push origin main || echo "No changes to push"