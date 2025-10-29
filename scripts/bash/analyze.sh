#!/usr/bin/env bash
# 分析小说结构

# 加载通用函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 获取项目路径
PROJECT_DIR=$(get_current_project "$1")

if [ -z "$PROJECT_DIR" ]; then
    output_json "{\"status\": \"error\", \"message\": \"未找到项目\"}"
    exit 1
fi

PROJECT_NAME=$(basename "$PROJECT_DIR")
NOVEL_FILE="$PROJECT_DIR/novel/original.txt"
ANALYSIS_FILE="$PROJECT_DIR/novel/analysis.md"

# 检查小说文件是否存在
if [ ! -f "$NOVEL_FILE" ]; then
    output_json "{\"status\": \"error\", \"message\": \"请先运行 /import 导入小说\"}"
    exit 1
fi

# 读取小说内容
novel_content=$(cat "$NOVEL_FILE")
word_count=$(count_script_words "$NOVEL_FILE")

# 检查是否已有分析
if [ -f "$ANALYSIS_FILE" ]; then
    existing_analysis=$(cat "$ANALYSIS_FILE")

    output_json "{
      \"status\": \"success\",
      \"action\": \"review\",
      \"project_name\": \"$PROJECT_NAME\",
      \"analysis_file\": \"$ANALYSIS_FILE\",
      \"novel_content\": \"$novel_content\",
      \"word_count\": $word_count,
      \"existing_analysis\": \"$existing_analysis\",
      \"message\": \"发现已有分析，AI可引导用户审查或更新\"
    }"
else
    # 创建分析模板
    cat > "$ANALYSIS_FILE" <<EOF
# 小说结构分析

## 基本信息
- 原文字数: ${word_count}字
- 分析日期: $(date '+%Y-%m-%d')

## 故事结构

### 主线情节
(AI将分析小说的主要情节线)

### 人物关系
(AI将分析主要角色及其关系)

### 关键情节点
(AI将提炼关键转折和冲突)

## 适合改编的特点
(AI将分析哪些部分适合视觉化呈现)

## 改编挑战
(AI将指出需要调整或删减的部分)

---
创建时间: $(date '+%Y-%m-%d %H:%M:%S')
EOF

    output_json "{
      \"status\": \"success\",
      \"action\": \"create\",
      \"project_name\": \"$PROJECT_NAME\",
      \"analysis_file\": \"$ANALYSIS_FILE\",
      \"novel_content\": \"$novel_content\",
      \"word_count\": $word_count,
      \"message\": \"已创建分析模板，AI应分析小说结构并填写\"
    }"
fi
