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

function dev() {
  if [[ -z "$TMUX" ]]; then
    echo "Not in a tmux session"
    return 1
  fi

  local agent="${1:-claude}"

  local nvim_pane
  nvim_pane=$(tmux new-window -n dev -c "$PWD" -P -F '#{pane_id}')

  # Split right for agent (full height, 32% width)
  local agent_pane
  agent_pane=$(tmux split-window -h -t "$nvim_pane" -c "$PWD" -l 32% -P -F '#{pane_id}')

  # Split neovim pane bottom for terminal (14% height, under neovim only)
  tmux split-window -v -t "$nvim_pane" -c "$PWD" -l 14%

  tmux send-keys -t "$nvim_pane" 'nvim' C-m
  tmux send-keys -t "$agent_pane" "$agent" C-m
  tmux select-pane -t "$nvim_pane"
}

function devk() {
  if [[ -z "$TMUX" ]]; then
    echo "Not in a tmux session"
    return 1
  fi

  local session
  session=$(tmux display-message -p '#{session_name}')
  local killed=0

  for win in $(tmux list-windows -t "$session" -F '#{window_index} #{window_name}' | grep ' dev$' | awk '{print $1}' | sort -rn); do
    tmux kill-window -t "$session:$win"
    ((killed++))
  done

  echo "Killed $killed dev window(s)"
}
