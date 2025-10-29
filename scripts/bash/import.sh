#!/usr/bin/env bash
# 导入小说

# 加载通用函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 参数解析
PROJECT_NAME=""
NOVEL_FILE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --project)
            PROJECT_NAME="$2"
            shift 2
            ;;
        --file)
            NOVEL_FILE="$2"
            shift 2
            ;;
        *)
            if [ -z "$PROJECT_NAME" ]; then
                PROJECT_NAME="$1"
            else
                NOVEL_FILE="$1"
            fi
            shift
            ;;
    esac
done

# 获取项目路径（工作区根目录）
PROJECT_DIR=$(get_current_project)
PROJECT_NAME=$(get_project_name)
PROJECT_NAME=$(basename "$PROJECT_DIR")
NOVEL_DIR="$PROJECT_DIR/novel"
IMPORTED_FILE="$NOVEL_DIR/original.txt"

# 创建小说目录
mkdir -p "$NOVEL_DIR"

# 复制小说文件
cp "$NOVEL_FILE" "$IMPORTED_FILE"

# 统计字数
word_count=$(count_script_words "$IMPORTED_FILE")

# 简单检测章节结构
chapter_count=$(grep -c "^第.章" "$IMPORTED_FILE" 2>/dev/null || echo "0")
if [ "$chapter_count" -eq 0 ]; then
    # 尝试其他章节格式
    chapter_count=$(grep -c "^Chapter\|^第.回" "$IMPORTED_FILE" 2>/dev/null || echo "0")
fi

# 输出结果
output_json "{
  \"status\": \"success\",
  \"project_name\": \"$PROJECT_NAME\",
  \"novel_file\": \"$IMPORTED_FILE\",
  \"original_file\": \"$NOVEL_FILE\",
  \"word_count\": $word_count,
  \"chapter_count\": $chapter_count,
  \"message\": \"小说导入成功\",
  \"next_steps\": [
    \"运行 /analyze 分析小说结构\",
    \"运行 /extract 提炼核心情节\"
  ]
}"
