#!/usr/bin/env bash
# 故事大纲

# 加载通用函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 获取项目路径（工作区根目录）
PROJECT_DIR=$(get_current_project)
PROJECT_NAME=$(get_project_name)

# 检查前置文件
SPEC_FILE=$(check_spec_exists)
IDEA_FILE="$PROJECT_DIR/idea.md"

if [ ! -f "$IDEA_FILE" ]; then
    output_json "{\"status\": \"error\", \"message\": \"请先运行 /idea 完成故事构思\"}"
    exit 1
fi

OUTLINE_FILE="$PROJECT_DIR/outline.md"
PROJECT_NAME=$(basename "$PROJECT_DIR")

# 读取已有内容
spec_content=$(cat "$SPEC_FILE")
idea_content=$(cat "$IDEA_FILE")

# 检查是否已有大纲
if [ -f "$OUTLINE_FILE" ]; then
    existing_outline=$(cat "$OUTLINE_FILE")
    word_count=$(count_script_words "$OUTLINE_FILE")

    output_json "{
      \"status\": \"success\",
      \"action\": \"review\",
      \"project_name\": \"$PROJECT_NAME\",
      \"outline_file\": \"$OUTLINE_FILE\",
      \"spec\": $spec_content,
      \"idea_content\": \"$idea_content\",
      \"existing_outline\": \"$existing_outline\",
      \"word_count\": $word_count,
      \"message\": \"发现已有大纲，AI 可引导用户审查或修改\"
    }"
else
    # 创建大纲模板
    cat > "$OUTLINE_FILE" <<EOF
# 故事大纲

## 三幕结构

### 第一幕：建置 (Setup)
**目标**: 介绍世界观、主角、日常生活

- 开场（Hook）：
- 主角的日常世界：
- 激励事件（Inciting Incident）：
- 第一幕转折点：

### 第二幕：对抗 (Confrontation)
**目标**: 主角面对困难、成长、挣扎

- 主角的计划：
- B故事线（副线）：
- 中点（Midpoint）转折：
- 低谷时刻（All is Lost）：
- 第二幕转折点：

### 第三幕：解决 (Resolution)
**目标**: 高潮对决、解决问题、完成弧线

- 主角的觉悟：
- 高潮对决：
- 结局：
- 尾声（如有）：

## 核心节拍（Beat Sheet）

1. 开场画面：
2. 主题陈述：
3. 铺陈：
4. 推动剂：
5. 争论：
6. 进入第二幕：
7. B故事线：
8. 娱乐时刻：
9. 中点：
10. 坏人逼近：
11. 一无所有：
12. 灵魂暗夜：
13. 进入第三幕：
14. 决战：
15. 结局：

---
创建时间: $(date '+%Y-%m-%d %H:%M:%S')
EOF

    output_json "{
      \"status\": \"success\",
      \"action\": \"create\",
      \"project_name\": \"$PROJECT_NAME\",
      \"outline_file\": \"$OUTLINE_FILE\",
      \"spec\": $spec_content,
      \"idea_content\": \"$idea_content\",
      \"message\": \"已创建大纲模板，AI 可根据模式引导用户填写\"
    }"
fi
