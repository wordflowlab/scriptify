#!/usr/bin/env bash
# 导出剧本

# 加载通用函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 参数解析
PROJECT_NAME=""
FORMAT="pdf"  # 默认PDF格式
EPISODE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --project)
            PROJECT_NAME="$2"
            shift 2
            ;;
        --format)
            FORMAT="$2"
            shift 2
            ;;
        --episode)
            EPISODE="$2"
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

PROJECT_NAME=$(basename "$PROJECT_DIR")
EXPORT_DIR="$PROJECT_DIR/export"
mkdir -p "$EXPORT_DIR"

# 检查格式
case $FORMAT in
    pdf|markdown|fountain|fdx)
        ;;
    *)
        output_json "{\"status\": \"error\", \"message\": \"不支持的格式: $FORMAT (支持: pdf, markdown, fountain, fdx)\"}"
        exit 1
        ;;
esac

# 确定要导出的文件
if [ -n "$EPISODE" ]; then
    # 导出指定集
    SCRIPT_FILE="$PROJECT_DIR/episodes/ep${EPISODE}.md"

    if [ ! -f "$SCRIPT_FILE" ]; then
        output_json "{\"status\": \"error\", \"message\": \"第${EPISODE}集不存在\"}"
        exit 1
    fi

    OUTPUT_FILE="$EXPORT_DIR/ep${EPISODE}.${FORMAT}"
    source_file="$SCRIPT_FILE"
    export_scope="第${EPISODE}集"
else
    # 导出所有集
    episode_count=$(ls -1 "$PROJECT_DIR/episodes"/ep*.md 2>/dev/null | wc -l | tr -d ' ')

    if [ "$episode_count" -eq 0 ]; then
        output_json "{\"status\": \"error\", \"message\": \"没有可导出的剧本\"}"
        exit 1
    fi

    OUTPUT_FILE="$EXPORT_DIR/${PROJECT_NAME}_complete.${FORMAT}"
    export_scope="全部 $episode_count 集"
fi

# 根据格式执行导出
# TODO: 实际导出功能需要后续实现（可能需要pandoc等工具）
# 目前只是占位，返回成功信息

output_json "{
  \"status\": \"success\",
  \"project_name\": \"$PROJECT_NAME\",
  \"format\": \"$FORMAT\",
  \"output_file\": \"$OUTPUT_FILE\",
  \"export_scope\": \"$export_scope\",
  \"message\": \"导出准备就绪\",
  \"note\": \"实际导出功能需要安装 pandoc 等工具，将在后续版本实现\"
}"
