#!/usr/bin/env bash
# 篇幅压缩

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

PROJECT_DIR=$(get_current_project "$1")
spec_content=$(cat "$SPEC_FILE")
extract_content=$(cat "$EXTRACT_FILE")

output_json "{
  \"status\": \"success\",
  \"project_name\": \"$PROJECT_NAME\",
  \"spec\": $spec_content,
  \"extract_content\": \"$extract_content\",
  \"message\": \"准备压缩篇幅，AI将根据剧本时长要求调整\"
}"
