#!/usr/bin/env bash
set -euo pipefail

# get-next-version.sh
# Calculate the next version based on the latest git tag and output GitHub Actions variables
# Usage: get-next-version.sh [version]
#   If version is provided, use it directly. Otherwise, auto-increment from latest tag.

USER_VERSION="$1"

# Get the latest tag, or use v0.0.0 if no tags exist
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")

# If user provided a version, use it directly
if [ -n "$USER_VERSION" ]; then
  # Ensure version starts with 'v' prefix
  if [[ ! "$USER_VERSION" =~ ^v ]]; then
    NEW_VERSION="v$USER_VERSION"
  else
    NEW_VERSION="$USER_VERSION"
  fi
  
  # If the user-specified version already exists as a tag, use the previous tag for release notes
  if git rev-parse "$NEW_VERSION" >/dev/null 2>&1; then
    # Get the tag before the specified version
    PREV_TAG=$(git describe --tags --abbrev=0 "$NEW_VERSION^" 2>/dev/null || echo "v0.0.0")
    LATEST_TAG="$PREV_TAG"
    echo "User-specified version $NEW_VERSION exists as tag, using previous tag $LATEST_TAG for release notes"
  else
    # Use current latest tag for release notes
    echo "User-specified version $NEW_VERSION is new, using latest tag $LATEST_TAG for release notes"
  fi
  
  echo "new_version=$NEW_VERSION" >> $GITHUB_OUTPUT
  echo "latest_tag=$LATEST_TAG" >> $GITHUB_OUTPUT
  echo "Using user-specified version: $NEW_VERSION"
else
  # Extract version number and increment
  VERSION=$(echo $LATEST_TAG | sed 's/v//')
  IFS='.' read -ra VERSION_PARTS <<< "$VERSION"
  MAJOR=${VERSION_PARTS[0]:-0}
  MINOR=${VERSION_PARTS[1]:-0}
  PATCH=${VERSION_PARTS[2]:-0}

  # Increment patch version
  PATCH=$((PATCH + 1))
  NEW_VERSION="v$MAJOR.$MINOR.$PATCH"

  echo "new_version=$NEW_VERSION" >> $GITHUB_OUTPUT
  echo "latest_tag=$LATEST_TAG" >> $GITHUB_OUTPUT
  echo "Auto-incremented version: $NEW_VERSION (from $LATEST_TAG)"
fi
