#!/usr/bin/env bash
# Apply GitHub repository topics (requires repo admin / gh auth with repo scope)
set -euo pipefail

TOPICS=$(tr '\n' ',' < "$(dirname "$0")/repository-topics.txt" | sed 's/,$//')
IFS=',' read -ra NAMES <<< "$TOPICS"

gh api --method PUT repos/btstevens1984az/PowerShell/topics \
  -H "Accept: application/vnd.github.mercy-preview+json" \
  --input <(python3 -c "import json,sys; print(json.dumps({'names': sys.argv[1:]}) )" "${NAMES[@]}")

echo "Repository topics applied:"
printf '  - %s\n' "${NAMES[@]}"
