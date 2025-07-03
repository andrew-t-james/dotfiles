#!/usr/bin/env bash

# ====================
# Git Worktree Clone Script
# ====================
# Description: Creates a bare git repository clone optimized for worktrees
# Author: Your Name
# Version: 1.0
#
# References:
# - https://nicknisi.com/posts/git-worktrees/
# - https://morgan.cugerone.com/blog/workarounds-to-git-worktree-using-bare-repository-and-cannot-fetch-remote-branches/

# ====================
# Strict Mode Settings
# ====================
set -euo pipefail # Exit on error, undefined vars, and pipe failures
IFS=$'\n\t'       # Set IFS to newline and tab for safer iteration

# ====================
# Help Documentation
# ====================
show_help() {
  cat <<EOF
Usage: $(basename "$0") <repository_url> [target_directory]

Clone a git repository in bare format for optimal worktree usage.

Arguments:
    repository_url     Git repository URL (required)
    target_directory   Target directory name (optional)
                       Defaults to repository name without .git extension

Examples:
    $(basename "$0") git@github.com:username/repo.git
    $(basename "$0") git@github.com:username/repo.git my-custom-dir

The script will create a directory structure like:
    target_directory/
    ├── .bare/        (Git administrative files)
    ├── main/         (Future worktree)
    ├── feature-1/    (Future worktree)
    └── ...
EOF
  exit 0
}

# ====================
# Error Handling
# ====================
error() {
  echo "Error: $1" >&2
  exit 1
}

# ====================
# Argument Validation
# ====================
# Check if no arguments or help flag
if [ $# -eq 0 ] || [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  show_help
fi

# Validate number of arguments
[ $# -lt 1 ] && error "Repository URL is required. Use --help for usage information."
[ $# -gt 2 ] && error "Too many arguments. Use --help for usage information."

# ====================
# Main Script
# ====================
# Parse arguments
url="$1"
basename=${url##*/}       # Extract the repository name from URL
name=${2:-${basename%.*}} # Use provided name or remove .git extension

# Validate URL format
if [[ ! "$url" =~ ^(https://|git@) ]]; then
  error "Invalid repository URL format. Must start with 'https://' or 'git@'"
fi

# Create and enter target directory
echo "Creating directory: $name"
if ! mkdir -p "$name"; then
  error "Failed to create directory: $name"
fi
cd "$name" || error "Failed to enter directory: $name"

# Clone bare repository
echo "Cloning bare repository..."
if ! git clone --bare "$url" .bare; then
  error "Failed to clone repository"
fi

# Setup git directory reference
echo "Setting up git directory reference..."
echo "gitdir: ./.bare" >.git

# Configure remote fetch settings
echo "Configuring remote settings..."

cd .bare || error "Failed to enter .bare directory"

# Get and verify the remote URL
REMOTE_URL=$(git config --get remote.origin.url)

if [ -z "$REMOTE_URL" ]; then
  error "No remote URL found. Repository setup failed."
fi

# Set the fetch configuration
git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"

echo "Remote configuration verified:"
echo "Remote URL: $REMOTE_URL"
echo "Fetch configuration: +refs/heads/*:refs/remotes/origin/*"

cd .. || error "Failed to return to parent directory"

# Fetch all branches
echo "Fetching remote branches..."
if ! git fetch origin; then
  error "Failed to fetch remote branches"
fi

# ====================
# Success Message
# ====================
cat <<EOF

Repository successfully cloned and configured for worktrees!
Location: $(pwd)

To create a new worktree:
  cd $name
  git worktree add <branch-name>

To list existing worktrees:
  git worktree list

EOF
