#!/usr/bin/env bash
# Hook检测(15种公式)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 参数解析
PROJECT_NAME=""
EPISODE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --project)
            PROJECT_NAME="$2"
            shift 2
            ;;
        --episode)
            EPISODE="$2"
            shift 2
            ;;
        *)
            PROJECT_NAME="$1"
            shift
            ;;
    esac
done

PROJECT_DIR=$(get_current_project "$PROJECT_NAME")
check_scope="第${EPISODE}集"
else
    SCRIPT_FILE="$PROJECT_DIR/episodes/ep1.md"
    check_scope="第1集(示例)"
fi

spec_content=$(cat "$SPEC_FILE")
script_content=$(cat "$SCRIPT_FILE" 2>/dev/null || echo "")

output_json "{
  \"status\": \"success\",
  \"project_name\": \"$PROJECT_NAME\",
  \"check_scope\": \"$check_scope\",
  \"script_file\": \"$SCRIPT_FILE\",
  \"spec\": $spec_content,
  \"script_content\": \"$script_content\",
  \"message\": \"准备检测Hook\",
  \"hook_formulas\": [
    \"冲突开场\", \"悬念开场\", \"反常开场\", \"金句开场\", \"高潮前置\",
    \"问题开场\", \"场景开场\", \"对比开场\", \"秘密开场\", \"意外开场\",
    \"时间压力\", \"身份反转\", \"悬疑线索\", \"情感冲击\", \"视觉冲击\"
  ],
  \"check_points\": [
    \"前3秒是否抓人?\",
    \"是否使用了15种Hook公式之一?\",
    \"是否立即引发好奇?\",
    \"是否避免了平淡铺垫?\"
  ]
}"
