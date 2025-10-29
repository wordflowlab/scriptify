#!/usr/bin/env bash
# 场景视觉化 - 将小说的文字描述转化为可拍摄的场景

# 加载通用函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 参数解析
PROJECT_NAME=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --project)
            PROJECT_NAME="$2"
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
# 读取spec和相关材料
spec_content=$(cat "$SPEC_FILE")
novel_content=$(cat "$NOVEL_FILE")
extracted_content=$(cat "$EXTRACTED_FILE")

# 统计小说字数
novel_words=$(echo "$novel_content" | tr -d '[:space:]' | grep -o . | wc -l | tr -d ' ')

# 检查是否已有可视化输出
VISUALIZED_FILE="$PROJECT_DIR/visualized.md"
if [ -f "$VISUALIZED_FILE" ]; then
    visualized_content=$(cat "$VISUALIZED_FILE")
    word_count=$(count_script_words "$VISUALIZED_FILE")

    output_json "{
      \"status\": \"success\",
      \"action\": \"review\",
      \"project_name\": \"$PROJECT_NAME\",
      \"visualized_file\": \"$VISUALIZED_FILE\",
      \"spec\": $spec_content,
      \"extracted_content\": \"$extracted_content\",
      \"visualized_content\": \"$visualized_content\",
      \"word_count\": $word_count,
      \"message\": \"已存在可视化场景,可以继续优化\"
    }"
else
    # 创建初始模板
    cat > "$VISUALIZED_FILE" <<EOF
# 场景视觉化

## 视觉化原则

- 将抽象描述转为具体画面
- 内心活动外化为动作和表情
- 静态描述动态化
- 确保每个场景都可拍摄

## 待视觉化场景

<!-- AI 将分析 extracted.md 中的场景,识别需要视觉化的部分 -->

---
创建时间: $(date '+%Y-%m-%d %H:%M:%S')
EOF

    output_json "{
      \"status\": \"success\",
      \"action\": \"create\",
      \"project_name\": \"$PROJECT_NAME\",
      \"visualized_file\": \"$VISUALIZED_FILE\",
      \"spec\": $spec_content,
      \"novel_words\": $novel_words,
      \"extracted_content\": \"$extracted_content\",
      \"message\": \"准备进行场景视觉化\"
    }"
fi
