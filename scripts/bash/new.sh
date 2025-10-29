#!/usr/bin/env bash
# 创建新剧本项目

# 加载通用函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 检查参数
if [ -z "$1" ]; then
    output_json "{\"status\": \"error\", \"message\": \"缺少必需参数: 项目名称\"}"
    exit 1
fi

PROJECT_NAME="$1"
PROJECTS_DIR=$(get_projects_dir)
PROJECT_PATH="$PROJECTS_DIR/$PROJECT_NAME"

# 检查项目是否已存在
if [ -d "$PROJECT_PATH" ]; then
    output_json "{\"status\": \"error\", \"message\": \"项目已存在: $PROJECT_NAME\"}"
    exit 1
fi

# 创建项目目录结构
mkdir -p "$PROJECT_PATH"
mkdir -p "$PROJECT_PATH/drafts"
mkdir -p "$PROJECT_PATH/episodes"
mkdir -p "$PROJECT_PATH/characters"
mkdir -p "$PROJECT_PATH/research"

# 创建初始文件
cat > "$PROJECT_PATH/README.md" <<EOF
# $PROJECT_NAME

创建时间: $(date '+%Y-%m-%d %H:%M:%S')

## 项目状态

- 阶段: 初始化
- 模式: 未设置（请运行 \`/spec\` 定义剧本规格）

## 目录结构

- \`spec.json\` - 剧本规格配置
- \`idea.md\` - 故事创意
- \`outline.md\` - 故事大纲
- \`characters/\` - 人物设定
- \`scene.md\` - 分场大纲
- \`episodes/\` - 分集剧本
- \`drafts/\` - 草稿版本
- \`research/\` - 调研资料

EOF

# 输出成功信息（JSON格式供AI使用）
output_json "{
  \"status\": \"success\",
  \"message\": \"项目创建成功\",
  \"project_name\": \"$PROJECT_NAME\",
  \"project_path\": \"$PROJECT_PATH\",
  \"next_steps\": [
    \"运行 /spec 定义剧本规格（类型、时长、题材等）\",
    \"运行 /idea 开始构思故事创意\",
    \"或运行 /import 导入小说进行改编\"
  ]
}"
