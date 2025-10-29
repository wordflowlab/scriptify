#!/usr/bin/env bash
# 爆点密度检测

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

PROJECT_DIR=$(get_current_project "$1")
spec_content=$(cat "$SPEC_FILE")
script_content=$(cat "$SCRIPT_FILE")

# 从spec中提取剧本类型
type=$(grep -o '"type": *"[^"]*"' "$SPEC_FILE" | cut -d'"' -f4)

# 根据类型确定爆点密度标准
case "$type" in
    "短视频")
        density_standard="1个爆点/15秒"
        ;;
    "短剧")
        density_standard="1个爆点/30秒"
        ;;
    *)
        density_standard="1个爆点/1-2分钟"
        ;;
esac

output_json "{
  \"status\": \"success\",
  \"project_name\": \"$PROJECT_NAME\",
  \"type\": \"$type\",
  \"density_standard\": \"$density_standard\",
  \"spec\": $spec_content,
  \"script_content\": \"$script_content\",
  \"message\": \"准备检测爆点密度\",
  \"explosion_types\": [
    \"反转\", \"冲突\", \"悬念\", \"笑点\", \"泪点\", \"意外\"
  ],
  \"check_method\": \"AI将分析剧本,标注每个爆点的时间戳和类型\"
}"
