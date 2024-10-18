#!/bin/bash
set -euo pipefail
set -x

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <tag_name> <build_id>"
    exit 1
fi

tag_name="$1"
build_id="$2"
echo "tag_name: $tag_name"
echo "build_id: $build_id"

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

# Create a new tag with build_id in the message
git tag -a "$tag_name" -m "Build ID: $build_id"

# Push the new tag to the remote repository
git push origin "$tag_name"

exit 0