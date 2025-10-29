#!/usr/bin/env bash
# 分场大纲

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
CHARACTERS_DIR="$PROJECT_DIR/characters"

if [ ! -d "$CHARACTERS_DIR" ] || [ -z "$(ls -A "$CHARACTERS_DIR" 2>/dev/null)" ]; then
    output_json "{\"status\": \"error\", \"message\": \"请先运行 /characters 完成人物设定\"}"
    exit 1
fi

SCENE_FILE="$PROJECT_DIR/scene.md"
PROJECT_NAME=$(basename "$PROJECT_DIR")

# 读取已有内容
spec_content=$(cat "$SPEC_FILE")

# 统计人物数量
character_count=$(ls -1 "$CHARACTERS_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')

# 检查是否已有分场大纲
if [ -f "$SCENE_FILE" ]; then
    existing_scene=$(cat "$SCENE_FILE")
    word_count=$(count_script_words "$SCENE_FILE")

    output_json "{
      \"status\": \"success\",
      \"action\": \"review\",
      \"project_name\": \"$PROJECT_NAME\",
      \"scene_file\": \"$SCENE_FILE\",
      \"spec\": $spec_content,
      \"character_count\": $character_count,
      \"existing_scene\": \"$existing_scene\",
      \"word_count\": $word_count,
      \"message\": \"发现已有分场大纲，AI 可引导用户审查或修改\"
    }"
else
    # 创建分场模板
    cat > "$SCENE_FILE" <<EOF
# 分场大纲

## 使用说明
每场戏应包含:
1. 场景位置（内/外）
2. 时间（日/夜/晨/昏）
3. 出场人物
4. 这场戏的目的
5. 冲突/张力
6. 结果/转折

---

## 第一幕

### 场次 1 - 开场
**位置**: 内/外 + 具体地点
**时间**: 日/夜
**人物**:

**目的**: （这场戏想达成什么）

**冲突**:

**结果**:

---

### 场次 2
**位置**:
**时间**:
**人物**:

**目的**:

**冲突**:

**结果**:

---

## 第二幕

### 场次 N
...

## 第三幕

### 场次 X
...

---
创建时间: $(date '+%Y-%m-%d %H:%M:%S')
EOF

    output_json "{
      \"status\": \"success\",
      \"action\": \"create\",
      \"project_name\": \"$PROJECT_NAME\",
      \"scene_file\": \"$SCENE_FILE\",
      \"spec\": $spec_content,
      \"character_count\": $character_count,
      \"message\": \"已创建分场模板，AI 应引导用户根据大纲和人物设定进行分场\",
      \"guidance\": \"根据规格中的集数和时长，计算每集需要多少场戏\"
    }"
fi
