# ====================
# Concatenate all files in a directory (and subdirectories)
# Usage: llm_txt <directory> <output_file>
# This function finds all files within the specified directory,
# concatenates their contents into the output file,
# and separates each file's content with a newline.
# ====================
llm_txt() {
  local dir="$1"    # The directory to search for files
  local output="$2" # The output file to write concatenated contents

  # Check if both arguments are provided
  if [ -z "$dir" ] || [ -z "$output" ]; then
    echo "Usage: llm_txt <directory> <output_file>"
    return 1
  fi

  # Find all files recursively within the directory
  # and concatenate their contents into the output file
  find "$dir" -type f -print0 | while IFS= read -r -d '' file; do
    cat "$file" >>"$output"  # Append file content to output
    echo -e "\n" >>"$output" # Add a newline separator
  done
}

function nic() {
  # Create a new window in the current tmux session with neovim, claude, and a terminal
  if [[ -z "$TMUX" ]]; then
    echo "Not in a tmux session"
    return 1
  fi

  # Create new window (becomes the neovim pane)
  local nvim_pane
  nvim_pane=$(tmux new-window -c "$PWD" -P -F '#{pane_id}')

  # Split bottom for full-width terminal (14% height)
  tmux split-window -v -t "$nvim_pane" -c "$PWD" -l 14%

  # Split the neovim pane right for Claude (32% width)
  local claude_pane
  claude_pane=$(tmux split-window -h -t "$nvim_pane" -c "$PWD" -l 32% -P -F '#{pane_id}')

  # Launch apps
  tmux send-keys -t "$nvim_pane" 'nvim' C-m
  tmux send-keys -t "$claude_pane" 'claude' C-m

  # Focus neovim
  tmux select-pane -t "$nvim_pane"
}
