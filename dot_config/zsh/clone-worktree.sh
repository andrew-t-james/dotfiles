clone_worktree() {
  local url name basename REMOTE_URL

  if [[ $# -eq 0 || "$1" == "--help" || "$1" == "-h" ]]; then
    cat <<EOF
Usage: clone_worktree <repository_url> [target_directory]

Clone a git repository in bare format for optimal worktree usage.

Arguments:
    repository_url     Git repository URL (required)
    target_directory   Target directory name (optional)
                       Defaults to repository name without .git extension

Examples:
    clone_worktree git@github.com:username/repo.git
    clone_worktree git@github.com:username/repo.git my-custom-dir

The function will create a directory structure like:
    target_directory/
    ├── .bare/        (Git administrative files)
    ├── main/         (Future worktree)
    ├── feature-1/    (Future worktree)
    └── ...
EOF
    return 0
  fi

  if [[ $# -lt 1 ]]; then
    echo "Error: Repository URL is required. Use --help for usage." >&2
    return 1
  fi

  if [[ $# -gt 2 ]]; then
    echo "Error: Too many arguments. Use --help for usage." >&2
    return 1
  fi

  url="$1"
  basename="${url##*/}"
  name="${2:-${basename%.git}}"

  if [[ ! "$url" =~ ^(https://|git@) ]]; then
    echo "Error: Invalid repository URL. Must start with 'https://' or 'git@'" >&2
    return 1
  fi

  echo "Creating directory: $name"
  mkdir -p "$name" || {
    echo "Error: Failed to create directory: $name" >&2
    return 1
  }
  cd "$name" || return 1

  echo "Cloning bare repository..."
  git clone --bare "$url" .bare || {
    echo "Error: Failed to clone repository" >&2
    return 1
  }

  echo "gitdir: ./.bare" >.git

  cd .bare || return 1
  REMOTE_URL=$(git config --get remote.origin.url)
  if [[ -z "$REMOTE_URL" ]]; then
    echo "Error: No remote URL found. Repository setup failed." >&2
    return 1
  fi

  git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
  cd .. || return 1

  echo "Fetching remote branches..."
  git fetch origin || {
    echo "Error: Failed to fetch remote branches" >&2
    return 1
  }

  echo
  echo "✅ Repository cloned and configured for worktrees!"
  echo "📁 Location: $(pwd)"
  echo
  echo "➕ To create a new worktree:"
  echo "   git worktree add <branch-name>"
  echo
  echo "📋 To list worktrees:"
  echo "   git worktree list"
  echo
}
