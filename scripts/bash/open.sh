#!/usr/bin/env bash
# 打开项目

# 加载通用函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 检查参数
if [ -z "$1" ]; then
    output_json "{\"status\": \"error\", \"message\": \"缺少必需参数: 项目名称\"}"
    exit 1
fi

PROJECT_NAME="$1"
PROJECT_DIR=$(check_project_exists "$PROJECT_NAME")

# 读取项目信息
if [ -f "$PROJECT_DIR/spec.json" ]; then
    spec_content=$(cat "$PROJECT_DIR/spec.json")
    has_spec=true
else
    spec_content="{}"
    has_spec=false
fi

# 统计项目进度
has_idea=false
has_outline=false
has_characters=false
has_scene=false
episode_count=0

[ -f "$PROJECT_DIR/idea.md" ] && has_idea=true
[ -f "$PROJECT_DIR/outline.md" ] && has_outline=true
[ -d "$PROJECT_DIR/characters" ] && [ -n "$(ls -A "$PROJECT_DIR/characters" 2>/dev/null)" ] && has_characters=true
[ -f "$PROJECT_DIR/scene.md" ] && has_scene=true

if [ -d "$PROJECT_DIR/episodes" ]; then
    episode_count=$(ls -1 "$PROJECT_DIR/episodes"/ep*.md 2>/dev/null | wc -l | tr -d ' ')
fi

# 输出项目状态
output_json "{
  \"status\": \"success\",
  \"project_name\": \"$PROJECT_NAME\",
  \"project_path\": \"$PROJECT_DIR\",
  \"progress\": {
    \"has_spec\": $has_spec,
    \"has_idea\": $has_idea,
    \"has_outline\": $has_outline,
    \"has_characters\": $has_characters,
    \"has_scene\": $has_scene,
    \"episode_count\": $episode_count
  },
  \"spec\": $spec_content,
  \"message\": \"项目已打开\",
  \"next_steps\": [
    \"查看项目进度\",
    \"继续未完成的步骤\",
    \"或直接跳到需要的命令\"
  ]
}"
