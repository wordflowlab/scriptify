#!/usr/bin/env bash
# 版本对比 - 对比剧本不同版本的差异

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

PROJECT_NAME=""
EPISODE=""
VERSION1=""
VERSION2=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --project) PROJECT_NAME="$2"; shift 2 ;;
        --episode) EPISODE="$2"; shift 2 ;;
        --v1) VERSION1="$2"; shift 2 ;;
        --v2) VERSION2="$2"; shift 2 ;;
        *) PROJECT_NAME="$1"; shift ;;
    esac
done

PROJECT_DIR=$(get_current_project "$PROJECT_NAME")
[ -z "$PROJECT_DIR" ] && output_json "{\"status\": \"error\", \"message\": \"未找到项目\"}" && exit 1

PROJECT_NAME=$(basename "$PROJECT_DIR")

if [ -z "$EPISODE" ]; then
    output_json "{\"status\": \"error\", \"message\": \"请指定集数 --episode N\"}" && exit 1
fi

SCRIPT_FILE="$PROJECT_DIR/episodes/ep${EPISODE}.md"
[ ! -f "$SCRIPT_FILE" ] && output_json "{\"status\": \"error\", \"message\": \"第${EPISODE}集不存在\"}" && exit 1

# 默认对比当前版本与Git历史
if [ -z "$VERSION1" ] && [ -z "$VERSION2" ]; then
    current_content=$(cat "$SCRIPT_FILE")
    current_words=$(count_script_words "$SCRIPT_FILE")

    # 尝试获取Git上一个版本
    prev_content=""
    if git rev-parse --git-dir > /dev/null 2>&1; then
        prev_content=$(git show HEAD:projects/$(basename "$PROJECT_DIR")/episodes/ep${EPISODE}.md 2>/dev/null || echo "")
    fi

    output_json "{
      \"status\": \"success\",
      \"project_name\": \"$PROJECT_NAME\",
      \"episode\": $EPISODE,
      \"current_content\": \"$current_content\",
      \"current_words\": $current_words,
      \"previous_content\": \"$prev_content\",
      \"has_history\": $([ -n "$prev_content" ] && echo "true" || echo "false"),
      \"message\": \"准备对比版本差异\"
    }"
else
    output_json "{\"status\": \"error\", \"message\": \"自定义版本对比功能开发中\"}" && exit 1
fi
