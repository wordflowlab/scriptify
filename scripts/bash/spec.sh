#!/usr/bin/env bash
# 定义/更新剧本规格

# 加载通用函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 获取项目路径（工作区根目录）
PROJECT_DIR=$(get_current_project)
PROJECT_NAME=$(get_project_name)

SPEC_FILE="$PROJECT_DIR/spec.json"

# 如果已有配置，读取现有配置
if [ -f "$SPEC_FILE" ]; then
    existing_config=$(cat "$SPEC_FILE")
    output_json "{
      \"status\": \"success\",
      \"action\": \"update\",
      \"project_name\": \"$PROJECT_NAME\",
      \"project_path\": \"$PROJECT_DIR\",
      \"spec_file\": \"$SPEC_FILE\",
      \"existing_config\": $existing_config,
      \"message\": \"找到现有配置，AI 可引导用户更新\"
    }"
else
    # 创建初始配置模板
    cat > "$SPEC_FILE" <<EOF
{
  "project_name": "$PROJECT_NAME",
  "type": "",
  "duration": "",
  "episodes": 0,
  "genre": "",
  "audience": {
    "age": "",
    "gender": ""
  },
  "target_platform": [],
  "tone": "",
  "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "updated_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF

    output_json "{
      \"status\": \"success\",
      \"action\": \"create\",
      \"project_name\": \"$PROJECT_NAME\",
      \"project_path\": \"$PROJECT_DIR\",
      \"spec_file\": \"$SPEC_FILE\",
      \"message\": \"已创建配置模板，AI 应引导用户填写以下信息\",
      \"required_fields\": [
        \"type (类型): 短剧/短视频/长剧/电影\",
        \"duration (时长): 如 '10分钟×10集' 或 '90分钟'\",
        \"genre (题材): 悬疑/言情/职场/古装等\",
        \"audience (受众): 年龄段和性别\",
        \"target_platform (目标平台): 抖音/快手/B站/长视频平台等\"
      ]
    }"
fi
