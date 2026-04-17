#!/bin/bash

# Check if gum is installed
if ! command -v gum &>/dev/null; then
  echo "Error: gum is not installed. Please install it first: https://github.com/charmbracelet/gum"
  exit 1
fi

# Header
gum style --border rounded --padding "0 2" --border-foreground 212 "🌐 Cloud Provider Status"
echo ""

# Helper function to style status
status_line() {
  local name="$1"
  local status="$2"
  local name_styled=$(gum style --foreground 212 --bold "$name")

  if echo "$status" | grep -qiE "operational|available|normally"; then
    status_styled=$(gum style --foreground 2 "✓ $status")
  else
    status_styled=$(gum style --foreground 1 --bold "⚠ $status")
  fi

  echo "$name_styled $status_styled"
}

# Fetch all statuses with a spinner
fetch_statuses() {
  github=$(curl -s https://www.githubstatus.com/api/v2/status.json | jq -r '.status.description')
  cloudflare=$(curl -s https://www.cloudflarestatus.com/api/v2/status.json | jq -r '.status.description')
  gcp=$(curl -s https://status.cloud.google.com/incidents.json | jq -r 'if length == 0 then "All Services Available" else "\(length) active incidents" end')
  aws_events=$(curl -s 'https://health.aws.amazon.com/public/currentevents' | jq 'length' 2>/dev/null || echo "0")
  linear=$(curl -s https://linearstatus.com/proxy/linearstatus.com | jq -r '.summary.ongoing_incidents | if length == 0 then "All Systems Operational" else "\(length) active incident(s)" end')
  claude=$(curl -s https://status.claude.com/api/v2/status.json | jq -r '.status.description')
  open_ai=$(curl -s https://status.openai.com/proxy/status.openai.com | jq -r '.summary.ongoing_incidents | if length == 0 then "All Systems Operational" else "\(length) active incident(s)" end')
}

gum spin --spinner dot --title "Fetching status..." -- bash -c "$(declare -f fetch_statuses); fetch_statuses"

# Re-fetch (gum spin runs in subshell)
github=$(curl -s https://www.githubstatus.com/api/v2/status.json | jq -r '.status.description')
cloudflare=$(curl -s https://www.cloudflarestatus.com/api/v2/status.json | jq -r '.status.description')
gcp=$(curl -s https://status.cloud.google.com/incidents.json | jq -r 'if length == 0 then "All Services Available" else "\(length) active incidents" end')
aws_events=$(curl -s 'https://health.aws.amazon.com/public/currentevents' | jq 'length' 2>/dev/null || echo "0")
if [ "$aws_events" -eq 0 ]; then
  aws="All Services Operating Normally"
else
  aws="${aws_events} active events"
fi
linear=$(curl -s https://linearstatus.com/proxy/linearstatus.com | jq -r '.summary.ongoing_incidents | if length == 0 then "All Systems Operational" else "\(length) active incident(s)" end')
claude=$(curl -s https://status.claude.com/api/v2/status.json | jq -r '.status.description')
open_ai=$(curl -s https://status.openai.com/proxy/status.openai.com | jq -r '.summary.ongoing_incidents | if length == 0 then "All Systems Operational" else "\(length) active incident(s)" end')

# Display
status_line "GitHub:    " "$github"
status_line "Cloudflare:" "$cloudflare"
status_line "GCP:       " "$gcp"
status_line "AWS:       " "$aws"
status_line "Linear:    " "$linear"
status_line "Claude:    " "$claude"
status_line "Open AI:   " "$open_ai"
