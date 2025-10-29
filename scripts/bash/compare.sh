#!/usr/bin/env bash
# 剧本比较 - 比较两个不同剧本的优劣

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

PROJECT_NAME=""
EPISODE1=""
EPISODE2=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --project) PROJECT_NAME="$2"; shift 2 ;;
        --ep1) EPISODE1="$2"; shift 2 ;;
        --ep2) EPISODE2="$2"; shift 2 ;;
        *) PROJECT_NAME="$1"; shift ;;
    esac
done

PROJECT_DIR=$(get_current_project "$PROJECT_NAME")
[ -z "$PROJECT_DIR" ] && output_json "{\"status\": \"error\", \"message\": \"未找到项目\"}" && exit 1

PROJECT_NAME=$(basename "$PROJECT_DIR")

if [ -z "$EPISODE1" ] || [ -z "$EPISODE2" ]; then
    output_json "{\"status\": \"error\", \"message\": \"请指定两集进行比较: --ep1 N --ep2 M\"}" && exit 1
fi

SCRIPT1="$PROJECT_DIR/episodes/ep${EPISODE1}.md"
SCRIPT2="$PROJECT_DIR/episodes/ep${EPISODE2}.md"

[ ! -f "$SCRIPT1" ] && output_json "{\"status\": \"error\", \"message\": \"第${EPISODE1}集不存在\"}" && exit 1
[ ! -f "$SCRIPT2" ] && output_json "{\"status\": \"error\", \"message\": \"第${EPISODE2}集不存在\"}" && exit 1

content1=$(cat "$SCRIPT1")
content2=$(cat "$SCRIPT2")
words1=$(count_script_words "$SCRIPT1")
words2=$(count_script_words "$SCRIPT2")

output_json "{
  \"status\": \"success\",
  \"project_name\": \"$PROJECT_NAME\",
  \"episode1\": $EPISODE1,
  \"episode2\": $EPISODE2,
  \"content1\": \"$content1\",
  \"content2\": \"$content2\",
  \"words1\": $words1,
  \"words2\": $words2,
  \"message\": \"准备比较两集剧本\"
}"
