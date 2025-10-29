#!/usr/bin/env bash
# 导入小说 - 智能扫描、格式检测、自动拆分

# 加载通用函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 配置
SPLIT_THRESHOLD=300000  # 30万字以上建议拆分
MAX_CHAPTER_SIZE=50000  # 单章最大字数(超过则按字数拆分)

# 获取项目路径
PROJECT_DIR=$(get_current_project)
PROJECT_NAME=$(get_project_name)
IMPORT_DIR="$PROJECT_DIR/import"
NOVEL_DIR="$PROJECT_DIR/novel"

# 检测文件编码
detect_encoding() {
    local file="$1"
    # 使用 file 命令检测
    local encoding=$(file -b --mime-encoding "$file")
    echo "$encoding"
}

# 转换编码到UTF-8
convert_to_utf8() {
    local file="$1"
    local encoding="$2"
    local output="$3"

    if [ "$encoding" = "utf-8" ] || [ "$encoding" = "us-ascii" ]; then
        cp "$file" "$output"
    else
        # 尝试从GBK/GB18030转换
        iconv -f GBK -t UTF-8 "$file" > "$output" 2>/dev/null || \
        iconv -f GB18030 -t UTF-8 "$file" > "$output" 2>/dev/null || \
        cp "$file" "$output"  # 转换失败就直接复制
    fi
}

# 检测章节格式
detect_chapter_pattern() {
    local file="$1"

    # 尝试多种章节格式
    local patterns=(
        "^第[0-9零一二三四五六七八九十百千]+章"
        "^第[0-9零一二三四五六七八九十百千]+回"
        "^Chapter [0-9]+"
        "^chapter [0-9]+"
        "^[0-9]+\\."
        "^[0-9]+、"
    )

    local best_pattern=""
    local max_count=0

    for pattern in "${patterns[@]}"; do
        local count=$(grep -c -E "$pattern" "$file" 2>/dev/null || echo "0")
        # 去除可能的空白字符
        count=$(echo "$count" | tr -d '[:space:]')
        if [ "$count" -gt "$max_count" ] 2>/dev/null; then
            max_count=$count
            best_pattern="$pattern"
        fi
    done

    if [ "$max_count" -gt 5 ]; then
        echo "$best_pattern|$max_count"
    else
        echo "none|0"
    fi
}

# 清理文本格式
clean_text() {
    local file="$1"
    local output="$2"

    # 1. 统一换行符(CRLF → LF)
    # 2. 去除行首空格
    # 3. 去除连续空行(保留最多1个)
    # 4. 去除尾部空白
    sed -e 's/\r$//' \
        -e 's/^[[:space:]]*//' \
        "$file" | \
    awk 'BEGIN{blank=0} /^$/{blank++; if(blank<=1) print; next} {blank=0; print}' > "$output"
}

# 按章节拆分
split_by_chapters() {
    local file="$1"
    local pattern="$2"
    local output_dir="$3"

    mkdir -p "$output_dir"

    # 使用awk按章节拆分
    local chapter_count=$(awk -v pattern="$pattern" -v outdir="$output_dir" '
    BEGIN {
        chapter = 0
        filename = ""
    }
    $0 ~ pattern {
        chapter++
        if (filename != "") close(filename)
        filename = sprintf("%s/chapter-%03d.txt", outdir, chapter)
        print > filename
        next
    }
    filename != "" {
        print >> filename
    }
    END {
        if (filename != "") close(filename)
        print chapter
    }
    ' "$file" | tail -1)

    echo "$chapter_count"
}

# 按字数拆分(如果没有章节结构)
split_by_size() {
    local file="$1"
    local chunk_size="$2"
    local output_dir="$3"

    mkdir -p "$output_dir"

    # 按行数拆分(粗略估算)
    local total_lines=$(wc -l < "$file")
    local total_words=$(count_script_words "$file")
    local lines_per_chunk=$((total_lines * chunk_size / total_words))

    if [ "$lines_per_chunk" -lt 100 ]; then
        lines_per_chunk=100
    fi

    split -l "$lines_per_chunk" -d -a 3 "$file" "$output_dir/chapter-"

    # 重命名为.txt
    local part_count=0
    for part in "$output_dir"/chapter-*; do
        if [ -f "$part" ]; then
            part_count=$((part_count + 1))
            mv "$part" "$part.txt"
        fi
    done

    echo "$part_count"
}

# 主流程
main() {
    # 创建必要目录
    mkdir -p "$IMPORT_DIR"
    mkdir -p "$NOVEL_DIR"

    # 1. 扫描 import/ 目录
    local txt_files=($(find "$IMPORT_DIR" -maxdepth 1 -type f \( -name "*.txt" -o -name "*.TXT" \)))

    if [ ${#txt_files[@]} -eq 0 ]; then
        output_json "{
          \"status\": \"error\",
          \"error_code\": \"NO_FILE\",
          \"message\": \"未找到待导入的TXT文件\",
          \"guide\": {
            \"step1\": \"请将下载的小说TXT文件放到以下目录:\",
            \"import_path\": \"$IMPORT_DIR\",
            \"step2\": \"然后重新运行 /import 命令\",
            \"tip\": \"支持UTF-8和GBK编码,系统会自动转换\"
          }
        }"
        exit 1
    fi

    # 如果有多个文件,选择最大的
    local novel_file="${txt_files[0]}"
    if [ ${#txt_files[@]} -gt 1 ]; then
        for file in "${txt_files[@]}"; do
            if [ $(stat -f%z "$file" 2>/dev/null || stat -c%s "$file") -gt $(stat -f%z "$novel_file" 2>/dev/null || stat -c%s "$novel_file") ]; then
                novel_file="$file"
            fi
        done
    fi

    local original_name=$(basename "$novel_file")

    # 2. 检测编码
    local encoding=$(detect_encoding "$novel_file")

    # 3. 转换编码并清理格式
    local temp_file="$NOVEL_DIR/temp_converted.txt"
    convert_to_utf8 "$novel_file" "$encoding" "$temp_file"

    local cleaned_file="$NOVEL_DIR/temp_cleaned.txt"
    clean_text "$temp_file" "$cleaned_file"
    rm -f "$temp_file"

    # 4. 统计字数
    local word_count=$(count_script_words "$cleaned_file")

    # 5. 检测章节结构
    local chapter_info=$(detect_chapter_pattern "$cleaned_file")
    local chapter_pattern=$(echo "$chapter_info" | cut -d'|' -f1)
    local chapter_count=$(echo "$chapter_info" | cut -d'|' -f2)

    # 6. 决定是否拆分
    local should_split=false
    local split_method="none"
    local actual_parts=0

    if [ "$word_count" -gt "$SPLIT_THRESHOLD" ]; then
        should_split=true

        if [ "$chapter_pattern" != "none" ] && [ "$chapter_count" -gt 10 ]; then
            # 按章节拆分
            split_method="chapter"
            actual_parts=$(split_by_chapters "$cleaned_file" "$chapter_pattern" "$NOVEL_DIR")
        else
            # 按字数拆分
            split_method="size"
            actual_parts=$(split_by_size "$cleaned_file" "$MAX_CHAPTER_SIZE" "$NOVEL_DIR")
        fi
    fi

    # 7. 保存原始文件
    cp "$cleaned_file" "$NOVEL_DIR/original.txt"
    rm -f "$cleaned_file"

    # 8. 输出结果
    if [ "$should_split" = true ]; then
        output_json "{
          \"status\": \"success\",
          \"project_name\": \"$PROJECT_NAME\",
          \"original_file\": \"$original_name\",
          \"encoding\": \"$encoding\",
          \"word_count\": $word_count,
          \"chapter_pattern\": \"$chapter_pattern\",
          \"chapter_count\": $chapter_count,
          \"split\": true,
          \"split_method\": \"$split_method\",
          \"parts_count\": $actual_parts,
          \"novel_dir\": \"$NOVEL_DIR\",
          \"files\": {
            \"original\": \"$NOVEL_DIR/original.txt\",
            \"parts\": \"$NOVEL_DIR/chapter-*.txt\"
          },
          \"message\": \"小说已导入并拆分为 $actual_parts 个文件\",
          \"recommendations\": [
            \"原文较长($word_count 字),已自动拆分以便处理\",
            \"完整原文保存在: novel/original.txt\",
            \"拆分文件保存在: novel/chapter-*.txt\",
            \"建议先运行 /analyze 分析小说结构\"
          ]
        }"
    else
        output_json "{
          \"status\": \"success\",
          \"project_name\": \"$PROJECT_NAME\",
          \"original_file\": \"$original_name\",
          \"encoding\": \"$encoding\",
          \"word_count\": $word_count,
          \"chapter_pattern\": \"$chapter_pattern\",
          \"chapter_count\": $chapter_count,
          \"split\": false,
          \"novel_dir\": \"$NOVEL_DIR\",
          \"files\": {
            \"original\": \"$NOVEL_DIR/original.txt\"
          },
          \"message\": \"小说导入成功\",
          \"recommendations\": [
            \"小说已保存到: novel/original.txt\",
            \"检测到 $chapter_count 个章节\",
            \"建议先运行 /analyze 分析小说结构\"
          ]
        }"
    fi
}

# 执行主流程
main "$@"
