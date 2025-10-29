#!/usr/bin/env bash
# AI优化建议 - 基于评估结果提供优化方案

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

PROJECT_NAME=""
EPISODE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --project) PROJECT_NAME="$2"; shift 2 ;;
        --episode) EPISODE="$2"; shift 2 ;;
        *) PROJECT_NAME="$1"; shift ;;
    esac
done

PROJECT_DIR=$(get_current_project "$PROJECT_NAME")
[ -z "$PROJECT_DIR" ] && output_json "{\"status\": \"error\", \"message\": \"未找到项目\"}" && exit 1

PROJECT_NAME=$(basename "$PROJECT_DIR")
SPEC_FILE=$(check_spec_exists)

if [ -z "$EPISODE" ]; then
    episode_count=$(ls -1 "$PROJECT_DIR/episodes"/ep*.md 2>/dev/null | wc -l | tr -d ' ')
    [ "$episode_count" -eq 0 ] && output_json "{\"status\": \"error\", \"message\": \"没有可优化的剧本\"}" && exit 1
    EPISODE=1
fi

SCRIPT_FILE="$PROJECT_DIR/episodes/ep${EPISODE}.md"
[ ! -f "$SCRIPT_FILE" ] && output_json "{\"status\": \"error\", \"message\": \"第${EPISODE}集不存在\"}" && exit 1

script_content=$(cat "$SCRIPT_FILE")
word_count=$(count_script_words "$SCRIPT_FILE")
spec_content=$(cat "$SPEC_FILE")

characters_content=""
[ -d "$PROJECT_DIR/characters" ] && for f in "$PROJECT_DIR/characters"/*.md; do
    [ -f "$f" ] && characters_content="$characters_content\n$(cat "$f")"
done

output_json "{
  \"status\": \"success\",
  \"project_name\": \"$PROJECT_NAME\",
  \"episode\": $EPISODE,
  \"script_file\": \"$SCRIPT_FILE\",
  \"spec\": $spec_content,
  \"script_content\": \"$script_content\",
  \"characters\": \"$characters_content\",
  \"word_count\": $word_count,
  \"message\": \"准备生成优化建议\"
}"
