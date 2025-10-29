#!/usr/bin/env bash
# 填充混合模式框架 - 智能辅助用户完成[用户填充]标记

# 加载通用函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 参数解析
PROJECT_NAME=""
EPISODE=""

# 解析参数
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
# 读取剧本内容
script_content=$(cat "$SCRIPT_FILE")

# 分析待填充项
fill_required=$(grep -c "\[必填.*用户填充" "$SCRIPT_FILE" || echo "0")
fill_suggested=$(grep -c "\[建议填充.*用户填充" "$SCRIPT_FILE" || echo "0")
fill_optional=$(grep -c "\[可选.*用户填充" "$SCRIPT_FILE" || echo "0")
fill_unmarked=$(grep "\[用户填充" "$SCRIPT_FILE" | grep -cv "\[必填\|\[建议填充\|\[可选" || echo "0")

total_fills=$((fill_required + fill_suggested + fill_optional + fill_unmarked))

# 如果没有待填充项
if [ "$total_fills" -eq 0 ]; then
    output_json "{
      \"status\": \"success\",
      \"action\": \"completed\",
      \"project_name\": \"$PROJECT_NAME\",
      \"episode\": $EPISODE,
      \"script_file\": \"$SCRIPT_FILE\",
      \"message\": \"该集所有填充项已完成\",
      \"suggestion\": \"可以运行 /review --episode $EPISODE 进行质量评估\"
    }"
    exit 0
fi

# 读取相关材料
SPEC_FILE="$PROJECT_DIR/spec.json"
CHARACTERS_DIR="$PROJECT_DIR/characters"

spec_content=""
if [ -f "$SPEC_FILE" ]; then
    spec_content=$(cat "$SPEC_FILE")
fi

# 收集人物设定
characters_content=""
if [ -d "$CHARACTERS_DIR" ]; then
    for char_file in "$CHARACTERS_DIR"/*.md; do
        [ -f "$char_file" ] || continue
        characters_content="$characters_content\n\n$(cat "$char_file")"
    done
fi

# 统计字数
current_words=$(count_script_words "$SCRIPT_FILE")

# 提取第一个待填充项作为示例
first_fill=$(grep -n "\[用户填充" "$SCRIPT_FILE" | head -1)
first_fill_line=$(echo "$first_fill" | cut -d: -f1)
first_fill_content=$(echo "$first_fill" | cut -d: -f2-)

# 提取填充上下文（前后3行）
context_start=$((first_fill_line - 3))
context_end=$((first_fill_line + 3))
if [ $context_start -lt 1 ]; then context_start=1; fi

fill_context=$(sed -n "${context_start},${context_end}p" "$SCRIPT_FILE")

# 输出结果
output_json "{
  \"status\": \"success\",
  \"action\": \"fill\",
  \"project_name\": \"$PROJECT_NAME\",
  \"episode\": $EPISODE,
  \"script_file\": \"$SCRIPT_FILE\",
  \"script_content\": \"$script_content\",
  \"fill_stats\": {
    \"required\": $fill_required,
    \"suggested\": $fill_suggested,
    \"optional\": $fill_optional,
    \"unmarked\": $fill_unmarked,
    \"total\": $total_fills
  },
  \"current_word_count\": $current_words,
  \"spec\": $spec_content,
  \"characters\": \"$characters_content\",
  \"first_fill_preview\": {
    \"line\": $first_fill_line,
    \"content\": \"$first_fill_content\",
    \"context\": \"$fill_context\"
  },
  \"message\": \"第${EPISODE}集有 $total_fills 个待填充项\"
}
"
