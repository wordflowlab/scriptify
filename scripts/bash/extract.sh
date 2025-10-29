#!/usr/bin/env bash
# 提炼核心情节

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
SPEC_FILE=$(check_project_config "$PROJECT_DIR")
ANALYSIS_FILE="$PROJECT_DIR/novel/analysis.md"
EXTRACT_FILE="$PROJECT_DIR/novel/extracted_plots.md"

# 检查前置文件
if [ ! -f "$ANALYSIS_FILE" ]; then
    output_json "{\"status\": \"error\", \"message\": \"请先运行 /analyze 分析小说结构\"}"
    exit 1
fi

# 读取已有内容
spec_content=$(cat "$SPEC_FILE")
analysis_content=$(cat "$ANALYSIS_FILE")

# 检查是否已有提炼结果
if [ -f "$EXTRACT_FILE" ]; then
    existing_extract=$(cat "$EXTRACT_FILE")

    output_json "{
      \"status\": \"success\",
      \"action\": \"review\",
      \"project_name\": \"$PROJECT_NAME\",
      \"extract_file\": \"$EXTRACT_FILE\",
      \"spec\": $spec_content,
      \"analysis_content\": \"$analysis_content\",
      \"existing_extract\": \"$existing_extract\",
      \"message\": \"发现已有提炼结果\"
    }"
else
    # 创建提炼模板
    cat > "$EXTRACT_FILE" <<EOF
# 核心情节提炼

## 提炼原则
根据剧本规格，从小说中提炼最核心的情节线。

## 主线情节(必保留)
### 情节点 1:
- 原文位置:
- 情节概要:
- 剧本化处理:

### 情节点 2:
...

## 副线情节(可选)
### 副线 1:
- 作用:
- 是否保留:
- 剧本化处理:

## 需要删减的部分
- 内心戏过多的部分
- 不适合视觉化的描写
- 与主线无关的支线

## 需要外化的部分
- 心理描写转为对话
- 回忆转为闪回场景
- 旁白转为具体事件

---
创建时间: $(date '+%Y-%m-%d %H:%M:%S')
EOF

    output_json "{
      \"status\": \"success\",
      \"action\": \"create\",
      \"project_name\": \"$PROJECT_NAME\",
      \"extract_file\": \"$EXTRACT_FILE\",
      \"spec\": $spec_content,
      \"analysis_content\": \"$analysis_content\",
      \"message\": \"已创建提炼模板，AI应根据剧本规格筛选核心情节\"
    }"
fi
