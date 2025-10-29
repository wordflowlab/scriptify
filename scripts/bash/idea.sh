#!/usr/bin/env bash
# 故事构思

# 加载通用函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 获取项目路径（工作区根目录）
PROJECT_DIR=$(get_current_project)
PROJECT_NAME=$(get_project_name)

# 检查配置文件
SPEC_FILE=$(check_spec_exists)
IDEA_FILE="$PROJECT_DIR/idea.md"

# 读取剧本规格
spec_content=$(cat "$SPEC_FILE")

# 检查是否已有创意文件
if [ -f "$IDEA_FILE" ]; then
    existing_idea=$(cat "$IDEA_FILE")
    word_count=$(count_script_words "$IDEA_FILE")

    output_json "{
      \"status\": \"success\",
      \"action\": \"review\",
      \"project_name\": \"$PROJECT_NAME\",
      \"idea_file\": \"$IDEA_FILE\",
      \"spec\": $spec_content,
      \"existing_idea\": \"$existing_idea\",
      \"word_count\": $word_count,
      \"message\": \"发现已有创意，AI 可引导用户审查或修改\"
    }"
else
    # 创建创意模板
    cat > "$IDEA_FILE" <<EOF
# 故事创意

## 故事核心

### 主角
- 姓名：
- 职业/身份：
- 年龄/性格：
- 核心特质：

### 目标
主角想要达成什么？

### 障碍
什么阻止主角达成目标？

### 人物弧线
主角如何成长/转变？（从A点到B点）

## 故事钩子
用一句话概括你的故事（30字以内）：

## 核心冲突

## 独特卖点
这个故事与众不同的地方：

---
创建时间: $(date '+%Y-%m-%d %H:%M:%S')
EOF

    output_json "{
      \"status\": \"success\",
      \"action\": \"create\",
      \"project_name\": \"$PROJECT_NAME\",
      \"idea_file\": \"$IDEA_FILE\",
      \"spec\": $spec_content,
      \"message\": \"已创建创意模板，AI 应引导用户思考并填写\",
      \"guidance\": \"通过提问引导用户思考，而不是替用户想创意\"
    }"
fi
