#!/usr/bin/env bash

# Reality Check - 市场现实检查

# 加载通用函数
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 获取项目路径
PROJECT_DIR=$(get_scriptify_root)
if [ $? -ne 0 ]; then
    output_error "NOT_IN_PROJECT" "未找到 .scriptify 项目目录。请先运行 scriptify new 创建项目。"
    exit 1
fi

PROJECT_NAME=$(get_project_name)
SPEC_FILE="$PROJECT_DIR/spec.json"
IDEA_FILE="$PROJECT_DIR/idea.md"

# 检查 spec.json 是否存在
if [ ! -f "$SPEC_FILE" ]; then
    output_error "SPEC_NOT_FOUND" "spec.json 未找到。请先运行 /spec 命令设置剧本规格。"
    exit 1
fi

# 检查 idea.md 是否存在
if [ ! -f "$IDEA_FILE" ]; then
    output_json '{
        "status": "error",
        "error_code": "IDEA_NOT_FOUND",
        "message": "请先运行 /idea 命令完成创意构思。市场检查需要基于你的故事创意进行。"
    }'
    exit 1
fi

# 读取 spec.json
SPEC_CONTENT=$(cat "$SPEC_FILE")
TYPE=$(echo "$SPEC_CONTENT" | grep -o '"type"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/"type"[[:space:]]*:[[:space:]]*"\([^"]*\)"/\1/')
GENRE=$(echo "$SPEC_CONTENT" | grep -o '"genre"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/"genre"[[:space:]]*:[[:space:]]*"\([^"]*\)"/\1/')
PLATFORM=$(echo "$SPEC_CONTENT" | grep -o '"target_platform"[[:space:]]*:[[:space:]]*\[[^]]*\]' | sed 's/"target_platform"[[:space:]]*:[[:space:]]*\[\([^]]*\)\]/\1/' | tr -d '"' | tr ',' ' ')

# 读取 idea.md 内容
IDEA_CONTENT=$(cat "$IDEA_FILE")

# 提取故事核心(一句话)
IDEA_SUMMARY=$(echo "$IDEA_CONTENT" | grep -A 1 "## 故事核心" | tail -n 1)

# 提取主角信息
PROTAGONIST_IDENTITY=$(echo "$IDEA_CONTENT" | grep -A 3 "## 主角" | grep "身份:" | sed 's/.*身份:[[:space:]]*//')
PROTAGONIST_TRAIT=$(echo "$IDEA_CONTENT" | grep -A 3 "## 主角" | grep "性格:" | sed 's/.*性格:[[:space:]]*//')

# 提取目标
GOAL=$(echo "$IDEA_CONTENT" | grep -A 3 "## 目标" | grep "目标:" | sed 's/.*目标:[[:space:]]*//')

# 提取障碍
EXTERNAL_OBSTACLE=$(echo "$IDEA_CONTENT" | grep -A 3 "## 障碍" | grep "外部障碍:" | sed 's/.*外部障碍:[[:space:]]*//')
INTERNAL_WEAKNESS=$(echo "$IDEA_CONTENT" | grep -A 3 "## 障碍" | grep "内部弱点:" | sed 's/.*内部弱点:[[:space:]]*//')

# 输出结果
output_json "{
    \"status\": \"success\",
    \"project_name\": \"$PROJECT_NAME\",
    \"project_path\": \"$PROJECT_DIR\",
    \"spec\": {
        \"type\": \"$TYPE\",
        \"genre\": \"$GENRE\",
        \"platform\": \"$PLATFORM\"
    },
    \"idea_summary\": \"$IDEA_SUMMARY\",
    \"protagonist\": {
        \"identity\": \"$PROTAGONIST_IDENTITY\",
        \"trait\": \"$PROTAGONIST_TRAIT\"
    },
    \"goal\": \"$GOAL\",
    \"obstacle\": {
        \"external\": \"$EXTERNAL_OBSTACLE\",
        \"internal\": \"$INTERNAL_WEAKNESS\"
    },
    \"idea_file\": \"$IDEA_FILE\",
    \"idea_content\": $(echo "$IDEA_CONTENT" | jq -Rs .)
}"
