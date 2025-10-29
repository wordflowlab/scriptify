#!/usr/bin/env bash
# 篇幅压缩 - 在保持核心情节的情况下压缩剧本长度

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

PROJECT_NAME=""
EPISODE=""
TARGET_WORDS=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --project) PROJECT_NAME="$2"; shift 2 ;;
        --episode) EPISODE="$2"; shift 2 ;;
        --target) TARGET_WORDS="$2"; shift 2 ;;
        *) PROJECT_NAME="$1"; shift ;;
    esac
done

PROJECT_DIR=$(get_current_project "$PROJECT_NAME")
[ -z "$PROJECT_DIR" ] && output_json "{\"status\": \"error\", \"message\": \"未找到项目\"}" && exit 1

PROJECT_NAME=$(basename "$PROJECT_DIR")
SPEC_FILE=$(check_project_config "$PROJECT_DIR")

[ -z "$EPISODE" ] && output_json "{\"status\": \"error\", \"message\": \"请指定集数 --episode N\"}" && exit 1

SCRIPT_FILE="$PROJECT_DIR/episodes/ep${EPISODE}.md"
[ ! -f "$SCRIPT_FILE" ] && output_json "{\"status\": \"error\", \"message\": \"第${EPISODE}集不存在\"}" && exit 1

script_content=$(cat "$SCRIPT_FILE")
current_words=$(count_script_words "$SCRIPT_FILE")
spec_content=$(cat "$SPEC_FILE")

# 从spec中读取目标字数,如果未指定
if [ -z "$TARGET_WORDS" ]; then
    TARGET_WORDS=$(echo "$spec_content" | grep -o '"target_words":[[:space:]]*[0-9]*' | grep -o '[0-9]*' | head -1)
    [ -z "$TARGET_WORDS" ] && TARGET_WORDS=$((current_words * 80 / 100))  # 默认压缩到80%
fi

output_json "{
  \"status\": \"success\",
  \"project_name\": \"$PROJECT_NAME\",
  \"episode\": $EPISODE,
  \"script_file\": \"$SCRIPT_FILE\",
  \"spec\": $spec_content,
  \"script_content\": \"$script_content\",
  \"current_words\": $current_words,
  \"target_words\": $TARGET_WORDS,
  \"compression_rate\": $((TARGET_WORDS * 100 / current_words)),
  \"message\": \"准备压缩剧本 (${current_words}字 → ${TARGET_WORDS}字)\"
}"
