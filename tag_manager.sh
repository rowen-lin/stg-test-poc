#!/bin/bash
set -euo pipefail
set -x

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <tag_name> <github_context_json>"
    exit 1
fi

tag_name="$1"
github_context="$2"

echo "tag_name: $tag_name"

parse_json() {
    local json="$1"
    local key="$2"
    echo "$json" | sed -E 's/.*"'"$key"'"\s*:\s*"([^"]+)".*/\1/'
}

pr_title=$(parse_json "$github_context" "pr_title")
merge_by=$(parse_json "$github_context" "merge_by")

echo "PR Title: $pr_title"
echo "Merged by: $merge_by"

# Remote tag handling
if git ls-remote --tags | grep -q -e "refs/tags/$tag_name$"; then
    # Delete the existing remote tag
    git push -d origin "$tag_name"
    echo "delete remote"
fi

# Local tag handling
if git show-ref --tags "refs/tags/$tag_name"; then
    # Delete the existing local tag
    git tag -d "$tag_name"
    echo "delete local"
fi

git tag -a "$tag_name" -m "PR Title: $pr_title
Merged by: $merge_by"

# Push the new tag to the remote repository
git push origin "$tag_name"

exit 0