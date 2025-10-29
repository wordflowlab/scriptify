#!/usr/bin/env bash
# 质量评估

# 加载通用函数库
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

# 获取项目路径（工作区根目录）
PROJECT_DIR=$(get_current_project)
PROJECT_NAME=$(get_project_name)
# 读取第一集作为示例
    SCRIPT_FILE="$PROJECT_DIR/episodes/ep1.md"
    script_content=$(cat "$SCRIPT_FILE")
    word_count=$(count_script_words "$SCRIPT_FILE")
    review_scope="全部 $episode_count 集（示例: 第1集）"
fi

spec_content=$(cat "$SPEC_FILE")

# 输出评估信息（AI将根据这些信息进行评估）
output_json "{
  \"status\": \"success\",
  \"project_name\": \"$PROJECT_NAME\",
  \"review_scope\": \"$review_scope\",
  \"script_file\": \"$SCRIPT_FILE\",
  \"spec\": $spec_content,
  \"script_content\": \"$script_content\",
  \"word_count\": $word_count,
  \"message\": \"准备评估剧本质量\",
  \"evaluation_dimensions\": [
    \"结构完整性 (30%): 三幕结构、节拍、转折点\",
    \"人物立体度 (25%): 人物弧线、性格一致性、动机合理性\",
    \"对话质量 (25%): 自然度、推动情节、符合人物性格\",
    \"节奏控制 (20%): 张弛有度、爆点密度、时长控制\"
  ]
}"
