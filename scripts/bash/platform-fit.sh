#!/usr/bin/env bash
# 平台适配度检测 - 检查剧本是否符合目标平台规范

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

PROJECT_NAME=""
EPISODE=""
PLATFORM=""  # douyin/kuaishou/xigua/iqiyi

while [[ $# -gt 0 ]]; do
    case $1 in
        --project) PROJECT_NAME="$2"; shift 2 ;;
        --episode) EPISODE="$2"; shift 2 ;;
        --platform) PLATFORM="$2"; shift 2 ;;
        *) PROJECT_NAME="$1"; shift ;;
    esac
done

PROJECT_DIR=$(get_current_project "$PROJECT_NAME")
[ -z "$PROJECT_DIR" ] && output_json "{\"status\": \"error\", \"message\": \"未找到项目\"}" && exit 1

PROJECT_NAME=$(basename "$PROJECT_DIR")
SPEC_FILE=$(check_spec_exists)

[ -z "$EPISODE" ] && output_json "{\"status\": \"error\", \"message\": \"请指定集数 --episode N\"}" && exit 1
[ -z "$PLATFORM" ] && PLATFORM="douyin"

SCRIPT_FILE="$PROJECT_DIR/episodes/ep${EPISODE}.md"
[ ! -f "$SCRIPT_FILE" ] && output_json "{\"status\": \"error\", \"message\": \"第${EPISODE}集不存在\"}" && exit 1

script_content=$(cat "$SCRIPT_FILE")
word_count=$(count_script_words "$SCRIPT_FILE")
spec_content=$(cat "$SPEC_FILE")

output_json "{
  \"status\": \"success\",
  \"project_name\": \"$PROJECT_NAME\",
  \"episode\": $EPISODE,
  \"platform\": \"$PLATFORM\",
  \"script_file\": \"$SCRIPT_FILE\",
  \"spec\": $spec_content,
  \"script_content\": \"$script_content\",
  \"word_count\": $word_count,
  \"message\": \"准备检测${PLATFORM}平台适配度\"
}"
