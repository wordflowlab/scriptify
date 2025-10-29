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

# 获取项目路径
PROJECT_DIR=$(get_current_project "$PROJECT_NAME")

if [ -z "$PROJECT_DIR" ]; then
    output_json "{\"status\": \"error\", \"message\": \"未找到项目\"}"
    exit 1
fi

PROJECT_NAME=$(basename "$PROJECT_DIR")
SPEC_FILE=$(check_project_config "$PROJECT_DIR")

# 如果未指定集数,列出所有可润色的剧本
if [ -z "$EPISODE" ]; then
    episodes_dir="$PROJECT_DIR/episodes"

    if [ ! -d "$episodes_dir" ]; then
        output_json "{
          \"status\": \"error\",
          \"message\": \"没有找到剧本文件\",
          \"suggestion\": \"请先创建剧本\"
        }"
        exit 1
    fi

    # 收集所有剧本信息
    episode_list=()
    for ep_file in "$episodes_dir"/ep*.md; do
        [ -f "$ep_file" ] || continue

        ep_num=$(basename "$ep_file" .md | sed 's/ep//')
        word_count=$(count_script_words "$ep_file")

        # 检查是否有[待润色]或[用户填充]标记
        needs_polish="false"
        if grep -q "\[待润色\|\[用户填充" "$ep_file"; then
            needs_polish="true"
        fi

        episode_list+=("{\"episode\": $ep_num, \"word_count\": $word_count, \"needs_polish\": $needs_polish, \"file\": \"$ep_file\"}")
    done

    # 组合JSON数组
    episodes_json=$(printf '%s\n' "${episode_list[@]}" | paste -sd ',' -)

    output_json "{
      \"status\": \"success\",
      \"action\": \"list\",
      \"project_name\": \"$PROJECT_NAME\",
      \"episodes\": [$episodes_json],
      \"message\": \"请选择要润色的集数\"
    }"
    exit 0
fi

# 指定了集数,准备润色
SCRIPT_FILE="$PROJECT_DIR/episodes/ep${EPISODE}.md"

if [ ! -f "$SCRIPT_FILE" ]; then
    output_json "{
      \"status\": \"error\",
      \"message\": \"第${EPISODE}集不存在\",
      \"suggestion\": \"请先创建该集剧本\"
    }"
    exit 1
fi

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
