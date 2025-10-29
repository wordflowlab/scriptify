#!/usr/bin/env bash
# 内心戏外化

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

PROJECT_DIR=$(get_current_project "$1")
if [ -z "$PROJECT_DIR" ]; then
    output_json "{\"status\": \"error\", \"message\": \"未找到项目\"}"
    exit 1
fi

PROJECT_NAME=$(basename "$PROJECT_DIR")
EXTRACT_FILE="$PROJECT_DIR/novel/extracted_plots.md"

if [ ! -f "$EXTRACT_FILE" ]; then
    output_json "{\"status\": \"error\", \"message\": \"请先运行 /extract 提炼情节\"}"
    exit 1
fi

extract_content=$(cat "$EXTRACT_FILE")

output_json "{
  \"status\": \"success\",
  \"project_name\": \"$PROJECT_NAME\",
  \"extract_content\": \"$extract_content\",
  \"message\": \"准备将内心戏外化，AI将使用四种技巧转换\",
  \"techniques\": [
    \"转为对话(与他人倾诉)\",
    \"转为独白/旁白(对镜自语、画外音)\",
    \"转为行动/表情(肢体语言展现)\",
    \"转为闪回/梦境(视觉化呈现)\"
  ]
}"
