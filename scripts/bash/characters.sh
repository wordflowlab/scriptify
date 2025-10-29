#!/usr/bin/env bash
# 人物设定

# 加载通用函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 获取项目路径
PROJECT_DIR=$(get_current_project "$1")

if [ -z "$PROJECT_DIR" ]; then
    output_json "{\"status\": \"error\", \"message\": \"未找到项目\"}"
    exit 1
fi

# 检查前置文件
SPEC_FILE=$(check_project_config "$PROJECT_DIR")
OUTLINE_FILE="$PROJECT_DIR/outline.md"

if [ ! -f "$OUTLINE_FILE" ]; then
    output_json "{\"status\": \"error\", \"message\": \"请先运行 /outline 完成故事大纲\"}"
    exit 1
fi

CHARACTERS_DIR="$PROJECT_DIR/characters"
PROJECT_NAME=$(basename "$PROJECT_DIR")

# 确保人物目录存在
mkdir -p "$CHARACTERS_DIR"

# 读取已有内容
spec_content=$(cat "$SPEC_FILE")
outline_content=$(cat "$OUTLINE_FILE")

# 检查是否已有人物设定
existing_characters=$(ls -1 "$CHARACTERS_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')

if [ "$existing_characters" -gt 0 ]; then
    # 读取所有人物文件
    characters_list=$(ls -1 "$CHARACTERS_DIR"/*.md 2>/dev/null | while read file; do
        basename "$file" .md
    done | tr '\n' ',' | sed 's/,$//')

    output_json "{
      \"status\": \"success\",
      \"action\": \"review\",
      \"project_name\": \"$PROJECT_NAME\",
      \"characters_dir\": \"$CHARACTERS_DIR\",
      \"existing_characters\": \"$characters_list\",
      \"character_count\": $existing_characters,
      \"spec\": $spec_content,
      \"outline_content\": \"$outline_content\",
      \"message\": \"发现 $existing_characters 个已有人物，AI 可引导用户审查或添加新人物\"
    }"
else
    # 创建主角模板
    cat > "$CHARACTERS_DIR/主角.md" <<EOF
# 主角设定

## 基本信息
- 姓名：
- 性别：
- 年龄：
- 职业：

## 外貌特征

## 性格特质
- 核心性格：
- 优点：
- 缺点/弱点：

## 背景故事

## 目标与动机
**核心目标**：

**深层动机**：

## 人物弧线
**起点（第一幕）**：

**转变过程（第二幕）**：

**终点（第三幕）**：

## 关系网
- 与其他角色的关系：

## 代表性台词/口头禅

---
创建时间: $(date '+%Y-%m-%d %H:%M:%S')
EOF

    output_json "{
      \"status\": \"success\",
      \"action\": \"create\",
      \"project_name\": \"$PROJECT_NAME\",
      \"characters_dir\": \"$CHARACTERS_DIR\",
      \"template_created\": \"主角.md\",
      \"spec\": $spec_content,
      \"outline_content\": \"$outline_content\",
      \"message\": \"已创建主角模板，AI 应引导用户填写人物设定\",
      \"next_steps\": [
        \"填写主角基本信息和性格特质\",
        \"定义人物弧线（从A点到B点的转变）\",
        \"根据需要创建其他角色（配角、反派等）\"
      ]
    }"
fi
