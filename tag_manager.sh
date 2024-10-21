#!/bin/bash
set -euo pipefail
set -x

# Function to install jq
install_jq() {
    echo "Attempting to install jq..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y jq
    elif command -v yum &> /dev/null; then
        sudo yum install -y jq
    elif command -v brew &> /dev/null; then
        brew install jq
    else
        echo "Error: Unable to install jq. Please install it manually."
        return 1
    fi
}

# Check if jq is installed, if not, try to install it
if ! command -v jq &> /dev/null; then
    install_jq || {
        echo "Failed to install jq. Falling back to built-in JSON parsing."
        parse_json() {
            local json="$1"
            local key="$2"
            local regex="\"$key\":\s*\"([^\"]*)\""
            if [[ $json =~ $regex ]]; then
                echo "${BASH_REMATCH[1]}"
            else
                echo ""
            fi
        }
    }
fi

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <tag_name> <github_context_json>"
    exit 1
fi

tag_name="$1"
github_context="$2"

echo "tag_name: $tag_name"

if command -v jq &> /dev/null; then
    pr_title=$(echo "$github_context" | jq -r '.pr_title')
    merged_by=$(echo "$github_context" | jq -r '.merged_by')
else
    echo "jq is not available. Using fallback method."
    pr_title=$(parse_json "$github_context" "pr_title")
    merged_by=$(parse_json "$github_context" "merged_by")
fi

echo "PR Title: $pr_title"
echo "Merged by: $merged_by"

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

# Create a new tag with pr_title and merge_by in the message
git tag -a "$tag_name" -m "PR Title: $pr_title | Merged by: $merge_by"

# Push the new tag to the remote repository
git push origin "$tag_name"

exit 0