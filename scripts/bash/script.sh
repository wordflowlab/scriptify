#!/usr/bin/env bash
# 生成剧本（支持三种模式）

# 加载通用函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 参数解析
PROJECT_NAME=""
EPISODE=""
MODE="coach"  # 默认教练模式

# 解析参数
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
        --mode)
            MODE="$2"
            shift 2
            ;;
        *)
            PROJECT_NAME="$1"
            shift
            ;;
    esac
done

# 获取项目路径
PROJECT_DIR=$(get_current_project "$PROJECT_NAME")

if [ -z "$PROJECT_DIR" ]; then
    output_json "{\"status\": \"error\", \"message\": \"未找到项目\"}"
    exit 1
fi

# 检查前置文件
SPEC_FILE=$(check_project_config "$PROJECT_DIR")
SCENE_FILE="$PROJECT_DIR/scene.md"

if [ ! -f "$SCENE_FILE" ]; then
    output_json "{\"status\": \"error\", \"message\": \"请先运行 /scene 完成分场大纲\"}"
    exit 1
fi

PROJECT_NAME=$(basename "$PROJECT_DIR")
EPISODES_DIR="$PROJECT_DIR/episodes"

# 确保episodes目录存在
mkdir -p "$EPISODES_DIR"

# 读取已有内容
spec_content=$(cat "$SPEC_FILE")
scene_content=$(cat "$SCENE_FILE")

# 如果指定了集数
if [ -n "$EPISODE" ]; then
    SCRIPT_FILE="$EPISODES_DIR/ep${EPISODE}.md"

    # 检查该集是否已存在
    if [ -f "$SCRIPT_FILE" ]; then
        existing_script=$(cat "$SCRIPT_FILE")
        word_count=$(count_script_words "$SCRIPT_FILE")

        output_json "{
          \"status\": \"success\",
          \"action\": \"review\",
          \"mode\": \"$MODE\",
          \"project_name\": \"$PROJECT_NAME\",
          \"episode\": $EPISODE,
          \"script_file\": \"$SCRIPT_FILE\",
          \"spec\": $spec_content,
          \"scene_content\": \"$scene_content\",
          \"existing_script\": \"$existing_script\",
          \"word_count\": $word_count,
          \"message\": \"发现第${EPISODE}集已存在，AI 可引导用户审查或修改\"
        }"
    else
        # 根据模式创建不同的模板
        if [ "$MODE" = "coach" ]; then
            # 教练模式：空白模板
            cat > "$SCRIPT_FILE" <<EOF
# 第${EPISODE}集

## 场次 1

**场景**: 内/外 + 地点，时间

（场景描述）

**角色名**
对话内容

（动作描述）

---

## 场次 2
...

---
创建时间: $(date '+%Y-%m-%d %H:%M:%S')
模式: 教练模式
EOF
            template_type="空白模板（教练模式）"
        elif [ "$MODE" = "hybrid" ]; then
            # 混合模式：框架模板
            cat > "$SCRIPT_FILE" <<EOF
# 第${EPISODE}集

<!-- AI 生成的结构框架 -->

## 场次 1 - [场景名称]

**场景**: [位置]，[时间]

<!-- 场景目的: [AI填写] -->

[AI生成的场景描述和对话框架]

**[角色名]**
[待用户填充的对话]

---

<!-- 用户需要填充: 具体对话内容、情感细节、动作描述 -->

---
创建时间: $(date '+%Y-%m-%d %H:%M:%S')
模式: 混合模式
EOF
            template_type="框架模板（混合模式）"
        else
            # 快速模式：AI完整生成
            cat > "$SCRIPT_FILE" <<EOF
# 第${EPISODE}集

<!-- AI 将生成完整剧本 -->

---
创建时间: $(date '+%Y-%m-%d %H:%M:%S')
模式: 快速模式
EOF
            template_type="AI生成模板（快速模式）"
        fi

        output_json "{
          \"status\": \"success\",
          \"action\": \"create\",
          \"mode\": \"$MODE\",
          \"project_name\": \"$PROJECT_NAME\",
          \"episode\": $EPISODE,
          \"script_file\": \"$SCRIPT_FILE\",
          \"spec\": $spec_content,
          \"scene_content\": \"$scene_content\",
          \"template_type\": \"$template_type\",
          \"message\": \"已创建第${EPISODE}集模板（${MODE}模式）\"
        }"
    fi
else
    # 未指定集数，返回概览
    existing_episodes=$(ls -1 "$EPISODES_DIR"/ep*.md 2>/dev/null | wc -l | tr -d ' ')

    output_json "{
      \"status\": \"success\",
      \"action\": \"overview\",
      \"project_name\": \"$PROJECT_NAME\",
      \"episodes_dir\": \"$EPISODES_DIR\",
      \"existing_episodes\": $existing_episodes,
      \"spec\": $spec_content,
      \"message\": \"请指定要创作的集数，如: /script --episode 1 --mode coach\"
    }"
fi
