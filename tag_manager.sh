#!/bin/bash

set -euo pipefail
set -x

if [ -z "${1:-}" ]; then
    echo "No tag name provided. Please provide a tag name as an argument."
    exit 1
fi

tag_name="$1"
echo "tag_name: $tag_name"

# remote
if git ls-remote --tags | grep -q -e "refs/tags/$tag_name$"; then
    # Delete the existing remote tag
    git push -d origin "$tag_name"
    echo "delete remote"
fi

# locally
if git show-ref --tags "refs/tags/$tag_name"; then
    # Delete the existing local tag
    git tag -d "$tag_name"
    echo "delete local"
fi

# Create a new tag
git tag "$tag_name"

# Push the new tag to the remote repository
git push origin "$tag_name"

exit 0