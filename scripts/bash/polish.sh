#!/usr/bin/env bash
# 剧本润色 - 最终精修优化

# 加载通用函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 参数解析
PROJECT_NAME=""
EPISODE=""
FOCUS=""  # 润色重点: dialogue|action|rhythm|all

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
        --focus)
            FOCUS="$2"
            shift 2
            ;;
        *)
            PROJECT_NAME="$1"
            shift
            ;;
    esac
done

# 默认润色重点
if [ -z "$FOCUS" ]; then
    FOCUS="all"
fi

# 获取项目路径（工作区根目录）
PROJECT_DIR=$(get_current_project)
PROJECT_NAME=$(get_project_name)
# 读取剧本内容
script_content=$(cat "$SCRIPT_FILE")
word_count=$(count_script_words "$SCRIPT_FILE")

# 读取spec和相关材料
spec_content=$(cat "$SPEC_FILE")

# 读取人物设定
characters_content=""
if [ -d "$PROJECT_DIR/characters" ]; then
    for char_file in "$PROJECT_DIR/characters"/*.md; do
        [ -f "$char_file" ] || continue
        characters_content="$characters_content\n\n$(cat "$char_file")"
    done
fi

# 读取场景大纲
scene_content=""
if [ -f "$PROJECT_DIR/scene.md" ]; then
    scene_content=$(cat "$PROJECT_DIR/scene.md")
fi

# 分析剧本特征
scene_count=$(grep -c "^##[[:space:]]*场次\|^##[[:space:]]*[0-9]" "$SCRIPT_FILE" || echo "0")
dialogue_count=$(grep -c "^\*\*.*\*\*$" "$SCRIPT_FILE" || echo "0")
has_issues=$(grep -c "\[待润色\|\[TODO\|\[FIXME\|\[用户填充" "$SCRIPT_FILE" || echo "0")

# 检测剧本模式
mode="unknown"
if grep -q "模式: 教练模式" "$SCRIPT_FILE"; then
    mode="coach"
elif grep -q "模式: 快速模式" "$SCRIPT_FILE"; then
    mode="express"
elif grep -q "模式: 混合模式" "$SCRIPT_FILE"; then
    mode="hybrid"
fi

# 输出润色信息
output_json "{
  \"status\": \"success\",
  \"action\": \"polish\",
  \"project_name\": \"$PROJECT_NAME\",
  \"episode\": $EPISODE,
  \"script_file\": \"$SCRIPT_FILE\",
  \"focus\": \"$FOCUS\",
  \"spec\": $spec_content,
  \"script_content\": \"$script_content\",
  \"characters\": \"$characters_content\",
  \"scene_outline\": \"$scene_content\",
  \"stats\": {
    \"word_count\": $word_count,
    \"scene_count\": $scene_count,
    \"dialogue_count\": $dialogue_count,
    \"has_issues\": $has_issues,
    \"mode\": \"$mode\"
  },
  \"message\": \"准备润色第${EPISODE}集\"
}
"
