#!/usr/bin/env bash
# 提炼核心情节 - 按目标集数分配内容

# 加载通用函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 获取项目路径
PROJECT_DIR=$(get_current_project)
PROJECT_NAME=$(get_project_name)
ANALYSIS_FILE="$PROJECT_DIR/analysis.md"
NOVEL_DIR="$PROJECT_DIR/novel"
EXTRACTED_FILE="$PROJECT_DIR/extracted.md"

# 参数解析
EPISODES=""
DURATION="10"  # 默认每集10分钟

while [[ $# -gt 0 ]]; do
    case $1 in
        --episodes)
            EPISODES="$2"
            shift 2
            ;;
        --duration)
            DURATION="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

# 主流程
main() {
    # 检查是否已有分析文件
    if [ ! -f "$ANALYSIS_FILE" ]; then
        output_json "{
          \"status\": \"error\",
          \"error_code\": \"NO_ANALYSIS\",
          \"message\": \"未找到分析文件,请先运行 /analyze\",
          \"guide\": {
            \"step1\": \"先运行 /analyze 分析小说结构\",
            \"step2\": \"然后再运行 /extract 提炼情节\"
          }
        }"
        exit 1
    fi

    # 检查小说文件
    if [ ! -f "$NOVEL_DIR/original.txt" ]; then
        output_json "{
          \"status\": \"error\",
          \"error_code\": \"NO_NOVEL\",
          \"message\": \"未找到小说文件\"
        }"
        exit 1
    fi

    # 统计信息
    local original_file="$NOVEL_DIR/original.txt"
    local word_count=$(count_script_words "$original_file")

    # 计算目标字数(每分钟约200字剧本)
    local target_words=0
    if [ -n "$EPISODES" ]; then
        target_words=$((EPISODES * DURATION * 200))
    fi

    # 计算删减比例
    local reduction_rate=0
    if [ "$target_words" -gt 0 ] && [ "$word_count" -gt 0 ]; then
        reduction_rate=$(awk "BEGIN {printf \"%.1f\", (($word_count - $target_words) / $word_count * 100)}")
    fi

    # 创建提炼文件模板
    cat > "$EXTRACTED_FILE" << EOF
# 核心情节提炼与分集大纲

**原小说**: $PROJECT_NAME
**原小说字数**: $word_count 字
**改编目标**: ${EPISODES}集 × ${DURATION}分钟
**目标字数**: 约 $target_words 字
**删减比例**: 约 ${reduction_rate}%
**提炼日期**: $(date '+%Y-%m-%d')

---

## 改编策略

### 删减比例

[待AI填充...]

### 保留重点

[待AI根据分析文件确定...]

### 删减内容

[待AI列出删减的支线和内容...]

---

## 分集大纲

### 第一幕 (第X-X集)

[待AI分配...]

#### 第1集: [标题]

**核心事件**: [待AI填充]
**对应原文**: 第X-X章
**Hook**: [开场抓人点]
**转折**: [本集转折]
**悬念**: [结尾悬念]
**本集冲突**: [主要冲突]
**字数**: 约XXX字

[继续为每集分配...]

---

## 下一步

1. 运行 /compress 进一步压缩篇幅
2. 运行 /visualize 将文字转为可拍摄场景
3. 运行 /externalize 外化内心戏
4. 最终运行 /script 生成剧本
EOF

    # 输出结果
    output_json "{
      \"status\": \"success\",
      \"project_name\": \"$PROJECT_NAME\",
      \"novel_info\": {
        \"word_count\": $word_count,
        \"original_file\": \"$original_file\"
      },
      \"target\": {
        \"episodes\": ${EPISODES:-0},
        \"duration\": $DURATION,
        \"target_words\": $target_words,
        \"reduction_rate\": \"${reduction_rate}%\"
      },
      \"analysis_file\": \"$ANALYSIS_FILE\",
      \"extracted_file\": \"$EXTRACTED_FILE\",
      \"message\": \"已创建提炼文件,请AI根据分析结果分配情节\",
      \"ai_task\": {
        \"instruction\": \"请根据分析文件和小说内容,提炼核心情节并按集数分配\",
        \"files_to_read\": [
          \"$ANALYSIS_FILE\",
          \"$original_file\"
        ],
        \"output_file\": \"$EXTRACTED_FILE\",
        \"requirements\": [
          \"为每集分配核心事件\",
          \"标注Hook和转折点\",
          \"设置集与集的悬念连接\",
          \"列出删减的内容\",
          \"确保三幕结构合理\"
        ]
      }
    }"
}

# 执行主流程
main "$@"
