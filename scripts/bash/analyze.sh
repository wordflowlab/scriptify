#!/usr/bin/env bash
# 小说结构分析 - 读取小说文件并提供基本信息给AI

# 加载通用函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 获取项目路径
PROJECT_DIR=$(get_current_project)
PROJECT_NAME=$(get_project_name)
NOVEL_DIR="$PROJECT_DIR/novel"
ANALYSIS_FILE="$PROJECT_DIR/analysis.md"

# 主流程
main() {
    # 检查novel目录是否存在
    if [ ! -d "$NOVEL_DIR" ]; then
        output_json "{
          \"status\": \"error\",
          \"error_code\": \"NO_NOVEL\",
          \"message\": \"未找到小说文件,请先运行 /import 导入小说\",
          \"guide\": {
            \"step1\": \"先运行 /import 命令导入小说\",
            \"step2\": \"然后再运行 /analyze 进行分析\"
          }
        }"
        exit 1
    fi

    # 检查是否有小说文件
    if [ ! -f "$NOVEL_DIR/original.txt" ]; then
        output_json "{
          \"status\": \"error\",
          \"error_code\": \"NO_NOVEL_FILE\",
          \"message\": \"novel目录中没有找到小说文件\"
        }"
        exit 1
    fi

    # 统计信息
    local original_file="$NOVEL_DIR/original.txt"
    local word_count=$(count_script_words "$original_file")

    # 检测章节
    local chapter_files=($NOVEL_DIR/chapter-*.txt)
    local chapter_count=0
    local has_chapters=false

    if [ -f "${chapter_files[0]}" ]; then
        has_chapters=true
        chapter_count=${#chapter_files[@]}
    else
        # 从原文件中检测章节数
        chapter_count=$(grep -c -E "^第[0-9零一二三四五六七八九十百千]+章" "$original_file" 2>/dev/null || echo "0")
    fi

    # 创建分析文件(空模板,由AI填充)
    cat > "$ANALYSIS_FILE" << 'EOF'
# 小说结构分析报告

> 此文件由 /analyze 命令生成,由AI填充分析内容

## 一、故事主线

[待AI分析...]

## 二、三幕结构

[待AI分析...]

## 三、支线分析

[待AI分析...]

## 四、关键情节点

[待AI分析...]

## 五、人物关系

[待AI分析...]

## 六、改编评估

[待AI分析...]

---

## 下一步

基于本分析,建议:
1. 运行 /extract 提炼核心情节
2. 明确改编目标(集数/时长)
3. 制定详细的分集大纲
EOF

    # 输出结果
    output_json "{
      \"status\": \"success\",
      \"project_name\": \"$PROJECT_NAME\",
      \"novel_info\": {
        \"word_count\": $word_count,
        \"chapter_count\": $chapter_count,
        \"has_chapters\": $has_chapters,
        \"original_file\": \"$original_file\",
        \"novel_dir\": \"$NOVEL_DIR\"
      },
      \"analysis_file\": \"$ANALYSIS_FILE\",
      \"message\": \"已创建分析文件,请AI根据小说内容完成深度分析\",
      \"ai_task\": {
        \"instruction\": \"请阅读小说内容并完成结构分析\",
        \"files_to_read\": [
          \"$original_file\"
        ],
        \"output_file\": \"$ANALYSIS_FILE\",
        \"analysis_dimensions\": [
          \"故事主线识别\",
          \"三幕结构划分\",
          \"支线重要性评估\",
          \"关键情节点标注\",
          \"人物关系网络\",
          \"改编难度评估\"
        ]
      }
    }"
}

# 执行主流程
main "$@"
