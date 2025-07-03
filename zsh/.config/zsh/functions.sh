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
