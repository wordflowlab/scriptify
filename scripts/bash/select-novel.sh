#!/usr/bin/env bash
# 漫剧选题检查 - 返回小说文件路径供AI评估

# 加载通用函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 获取项目路径
PROJECT_DIR=$(get_current_project)
PROJECT_NAME=$(get_project_name)
NOVEL_DIR="$PROJECT_DIR/novel"
IMPORT_DIR="$PROJECT_DIR/import"

# 主流程
main() {
    local novel_file=""
    local file_source=""

    # 1. 确定小说文件路径
    if [ $# -gt 0 ]; then
        # 用户提供了文件路径参数
        local input_path="$1"

        # 如果是相对路径,转为绝对路径
        if [[ "$input_path" != /* ]]; then
            input_path="$PROJECT_DIR/$input_path"
        fi

        if [ ! -f "$input_path" ]; then
            output_json "{
              \"status\": \"error\",
              \"error_code\": \"FILE_NOT_FOUND\",
              \"message\": \"未找到指定的文件: $input_path\",
              \"guide\": {
                \"tip1\": \"请检查文件路径是否正确\",
                \"tip2\": \"支持的路径格式:\",
                \"examples\": [
                  \"novel/original.txt\",
                  \"import/my-novel.txt\",
                  \"/absolute/path/to/novel.txt\"
                ]
              }
            }"
            exit 1
        fi

        novel_file="$input_path"
        file_source="user_specified"
    else
        # 未提供参数,使用默认文件 novel/original.txt
        if [ -f "$NOVEL_DIR/original.txt" ]; then
            novel_file="$NOVEL_DIR/original.txt"
            file_source="default"
        else
            # 尝试在import目录找TXT文件
            local txt_files=($(find "$IMPORT_DIR" -maxdepth 1 -type f \( -name "*.txt" -o -name "*.TXT" \) 2>/dev/null))

            if [ ${#txt_files[@]} -gt 0 ]; then
                # 选择最大的文件
                novel_file="${txt_files[0]}"
                for file in "${txt_files[@]}"; do
                    if [ $(stat -f%z "$file" 2>/dev/null || stat -c%s "$file") -gt $(stat -f%z "$novel_file" 2>/dev/null || stat -c%s "$novel_file") ]; then
                        novel_file="$file"
                    fi
                done
                file_source="import_dir"
            else
                # 没有找到任何小说文件
                output_json "{
                  \"status\": \"error\",
                  \"error_code\": \"NO_FILE\",
                  \"message\": \"未找到小说文件\",
                  \"guide\": {
                    \"step1\": \"请先运行以下命令之一:\",
                    \"option1\": \"/import - 导入新小说\",
                    \"option2\": \"/select-novel <文件路径> - 指定小说文件\",
                    \"import_dir\": \"$IMPORT_DIR\",
                    \"examples\": [
                      \"/select-novel import/my-novel.txt\",
                      \"/select-novel novel/original.txt\"
                    ]
                  }
                }"
                exit 1
            fi
        fi
    fi

    # 2. 获取文件基本信息
    local file_size=$(stat -f%z "$novel_file" 2>/dev/null || stat -c%s "$novel_file")
    local file_name=$(basename "$novel_file")
    local word_count=$(count_script_words "$novel_file")

    # 3. 检查文件是否为空
    if [ "$word_count" -lt 100 ]; then
        output_json "{
          \"status\": \"error\",
          \"error_code\": \"EMPTY_FILE\",
          \"message\": \"文件内容过少或为空\",
          \"file_info\": {
            \"path\": \"$novel_file\",
            \"size\": $file_size,
            \"word_count\": $word_count
          },
          \"guide\": {
            \"tip\": \"文件字数少于100字,无法进行评估\",
            \"suggestion\": \"请检查文件是否正确,或重新导入小说\"
          }
        }"
        exit 1
    fi

    # 4. 返回成功信息
    output_json "{
      \"status\": \"success\",
      \"project_name\": \"$PROJECT_NAME\",
      \"file_info\": {
        \"path\": \"$novel_file\",
        \"relative_path\": \"$(realpath --relative-to=\"$PROJECT_DIR\" \"$novel_file\" 2>/dev/null || echo \"$novel_file\")\",
        \"name\": \"$file_name\",
        \"size\": $file_size,
        \"word_count\": $word_count,
        \"source\": \"$file_source\"
      },
      \"message\": \"找到小说文件,准备进行漫剧适配性评估\",
      \"next_steps\": [
        \"AI将读取小说开篇(前5000字)\",
        \"根据五大核心筛选标准进行评估\",
        \"生成适配性报告和改编建议\"
      ],
      \"evaluation_standards\": [
        \"标准1: 数据基础达标(评分≥8.0, 在读≥1万)\",
        \"标准2: 开篇吸引力强(前3句话内有冲突)\",
        \"标准3: 主线清晰明确(剧情连贯,目标单一)\",
        \"标准4: 情绪衔接流畅(无情绪断层)\",
        \"标准5: 适配漫剧风格(热血/甜宠/沙雕/悬疑)\"
      ]
    }"
}

# 执行主流程
main "$@"
