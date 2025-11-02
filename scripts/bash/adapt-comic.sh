#!/usr/bin/env bash
# 漫剧改编 - 解析参数并准备改编环境

# 加载通用函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 获取项目路径
PROJECT_DIR=$(get_current_project)
PROJECT_NAME=$(get_project_name)
NOVEL_DIR="$PROJECT_DIR/novel"
COMIC_DIR="$PROJECT_DIR/comic-scripts"

# 默认值
STYLE=""
EPISODES=""
MODE="interactive"
NOVEL_FILE=""

# 解析参数
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --style)
                STYLE="$2"
                shift 2
                ;;
            --episodes)
                EPISODES="$2"
                shift 2
                ;;
            --auto)
                MODE="auto"
                shift
                ;;
            *)
                # 未识别的参数,可能是文件路径
                if [ -z "$NOVEL_FILE" ]; then
                    NOVEL_FILE="$1"
                fi
                shift
                ;;
        esac
    done
}

# 验证风格参数
validate_style() {
    local style="$1"
    case $style in
        沙雕|热血|甜宠|悬疑)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# 主流程
main() {
    # 解析命令行参数
    parse_arguments "$@"

    # 1. 确定小说文件
    if [ -z "$NOVEL_FILE" ]; then
        # 未指定文件,使用默认
        if [ -f "$NOVEL_DIR/original.txt" ]; then
            NOVEL_FILE="$NOVEL_DIR/original.txt"
        else
            output_json "{
              \"status\": \"error\",
              \"error_code\": \"NO_FILE\",
              \"message\": \"未找到小说文件\",
              \"guide\": {
                \"step1\": \"请先运行以下命令之一:\",
                \"option1\": \"/import - 导入小说\",
                \"option2\": \"/select-novel - 检查小说适配度\",
                \"then\": \"然后再运行 /adapt-comic\"
              }
            }"
            exit 1
        fi
    else
        # 转换为绝对路径
        if [[ "$NOVEL_FILE" != /* ]]; then
            NOVEL_FILE="$PROJECT_DIR/$NOVEL_FILE"
        fi

        if [ ! -f "$NOVEL_FILE" ]; then
            output_json "{
              \"status\": \"error\",
              \"error_code\": \"FILE_NOT_FOUND\",
              \"message\": \"未找到指定的小说文件: $NOVEL_FILE\"
            }"
            exit 1
        fi
    fi

    # 2. 获取小说基本信息
    local word_count=$(count_script_words "$NOVEL_FILE")
    local file_name=$(basename "$NOVEL_FILE")

    # 3. 建议集数(如果未指定)
    local suggested_episodes=""
    if [ -z "$EPISODES" ]; then
        if [ "$word_count" -lt 50000 ]; then
            suggested_episodes="20-30"
        elif [ "$word_count" -lt 150000 ]; then
            suggested_episodes="50-80"
        elif [ "$word_count" -lt 300000 ]; then
            suggested_episodes="80-120"
        else
            suggested_episodes="100-150"
        fi
    fi

    # 4. 验证风格(如果已指定)
    if [ -n "$STYLE" ]; then
        if ! validate_style "$STYLE"; then
            output_json "{
              \"status\": \"error\",
              \"error_code\": \"INVALID_STYLE\",
              \"message\": \"无效的风格参数: $STYLE\",
              \"valid_styles\": [\"沙雕\", \"热血\", \"甜宠\", \"悬疑\"]
            }"
            exit 1
        fi
    fi

    # 5. 创建输出目录
    mkdir -p "$COMIC_DIR"

    # 6. 准备改编配置
    local config_file="$COMIC_DIR/.adapt-config.json"
    cat > "$config_file" <<EOF
{
  "novel_file": "$NOVEL_FILE",
  "word_count": $word_count,
  "style": "$STYLE",
  "episodes": "$EPISODES",
  "mode": "$MODE",
  "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF

    # 7. 返回结果
    if [ -n "$STYLE" ] && [ -n "$EPISODES" ]; then
        # 参数完整,可以开始改编
        output_json "{
          \"status\": \"ready\",
          \"project_name\": \"$PROJECT_NAME\",
          \"novel_info\": {
            \"file\": \"$NOVEL_FILE\",
            \"name\": \"$file_name\",
            \"word_count\": $word_count
          },
          \"settings\": {
            \"style\": \"$STYLE\",
            \"episodes\": $EPISODES,
            \"mode\": \"$MODE\"
          },
          \"output_dir\": \"$COMIC_DIR\",
          \"message\": \"改编参数已设置,准备开始改编\",
          \"next_steps\": [
            \"AI将读取小说内容\",
            \"生成漫剧章纲(所有集)\",
            \"逐集生成剧本(${MODE}模式)\",
            \"自动质量检查\",
            \"保存到: $COMIC_DIR\"
          ]
        }"
    else
        # 参数不完整,需要询问用户
        local need_params=[]
        if [ -z "$STYLE" ]; then
            need_params+=("\"style\"")
        fi
        if [ -z "$EPISODES" ]; then
            need_params+=("\"episodes\"")
        fi

        output_json "{
          \"status\": \"need_input\",
          \"project_name\": \"$PROJECT_NAME\",
          \"novel_info\": {
            \"file\": \"$NOVEL_FILE\",
            \"name\": \"$file_name\",
            \"word_count\": $word_count
          },
          \"current_settings\": {
            \"style\": \"${STYLE:-null}\",
            \"episodes\": ${EPISODES:-null},
            \"mode\": \"$MODE\"
          },
          \"need_params\": [$(IFS=,; echo "${need_params[*]}")],
          \"suggestions\": {
            \"style_options\": [
              {\"value\": \"沙雕\", \"desc\": \"夸张反差、密集笑点\"},
              {\"value\": \"热血\", \"desc\": \"打脸升级、爽点密集\"},
              {\"value\": \"甜宠\", \"desc\": \"糖点密集、情感互动\"},
              {\"value\": \"悬疑\", \"desc\": \"伏笔悬念、反转钩子\"}
            ],
            \"episodes_range\": \"$suggested_episodes\"
          },
          \"message\": \"请补充改编参数\",
          \"guide\": {
            \"tip\": \"AI将根据小说内容询问缺失的参数\"
          }
        }"
    fi
}

# 执行主流程
main "$@"
