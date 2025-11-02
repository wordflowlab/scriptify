#!/usr/bin/env bash
# 漫剧质量检查 - 获取剧本文件并返回基本信息

# 加载通用函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 获取项目路径
PROJECT_DIR=$(get_current_project)
PROJECT_NAME=$(get_project_name)
COMIC_DIR="$PROJECT_DIR/comic-scripts"

# 检查是否为批量模式
CHECK_ALL=false
if [[ "$1" == "--all" ]]; then
    CHECK_ALL=true
fi

# 估算时长(按配音语速: 1秒≈3个汉字)
estimate_duration() {
    local file="$1"
    local word_count=$(count_script_words "$file")
    echo $((word_count / 3))
}

# 统计对白数量
count_dialogues() {
    local file="$1"
    # 统计"**[角色名]**:"的数量,排除旁白
    grep -c "^\*\*\[.*\]\*\*:" "$file" 2>/dev/null || echo "0"
}

# 提取集数
extract_episode_number() {
    local filename="$1"
    # 从文件名提取数字: episode-1.md → 1
    echo "$filename" | sed -n 's/.*episode-\([0-9]*\)\.md/\1/p'
}

# 批量检查
batch_check() {
    local episode_files=($(find "$COMIC_DIR" -name "episode-*.md" | sort))

    if [ ${#episode_files[@]} -eq 0 ]; then
        output_json "{
          \"status\": \"error\",
          \"error_code\": \"NO_EPISODES\",
          \"message\": \"未找到任何剧本文件\",
          \"comic_dir\": \"$COMIC_DIR\"
        }"
        exit 1
    fi

    # 构建批量结果
    local episodes_json="["
    local first=true

    for episode_file in "${episode_files[@]}"; do
        local episode_num=$(extract_episode_number "$(basename "$episode_file")")
        local word_count=$(count_script_words "$episode_file")
        local dialogue_count=$(count_dialogues "$episode_file")
        local duration=$(estimate_duration "$episode_file")

        if [ "$first" = true ]; then
            first=false
        else
            episodes_json+=","
        fi

        episodes_json+="{ \"episode\": $episode_num, \"file\": \"$episode_file\", \"word_count\": $word_count, \"dialogue_count\": $dialogue_count, \"duration_estimate\": $duration }"
    done

    episodes_json+="]"

    output_json "{
      \"status\": \"batch\",
      \"project_name\": \"$PROJECT_NAME\",
      \"total_episodes\": ${#episode_files[@]},
      \"episodes\": $episodes_json,
      \"message\": \"批量检查模式,将逐一检查所有集\"
    }"
}

# 单集检查
single_check() {
    local episode_file=""

    # 1. 确定剧本文件
    if [ -n "$1" ] && [ "$1" != "--all" ]; then
        # 用户指定了文件
        local input_path="$1"

        # 转换为绝对路径
        if [[ "$input_path" != /* ]]; then
            input_path="$PROJECT_DIR/$input_path"
        fi

        if [ ! -f "$input_path" ]; then
            output_json "{
              \"status\": \"error\",
              \"error_code\": \"FILE_NOT_FOUND\",
              \"message\": \"未找到指定的剧本文件: $input_path\",
              \"guide\": {
                \"tip1\": \"请检查文件路径是否正确\",
                \"tip2\": \"或先运行 /adapt-comic 生成剧本\"
              }
            }"
            exit 1
        fi

        episode_file="$input_path"
    else
        # 未指定,查找最新的episode文件
        local latest=$(find "$COMIC_DIR" -name "episode-*.md" -type f | sort -r | head -1)

        if [ -z "$latest" ]; then
            output_json "{
              \"status\": \"error\",
              \"error_code\": \"NO_EPISODES\",
              \"message\": \"未找到漫剧剧本文件\",
              \"guide\": {
                \"step1\": \"请先运行 /adapt-comic 生成漫剧剧本\",
                \"step2\": \"或指定剧本文件:\",
                \"example\": \"/quality-check-comic comic-scripts/episode-1.md\"
              }
            }"
            exit 1
        fi

        episode_file="$latest"
    fi

    # 2. 提取基本信息
    local file_name=$(basename "$episode_file")
    local episode_num=$(extract_episode_number "$file_name")
    local word_count=$(count_script_words "$episode_file")
    local dialogue_count=$(count_dialogues "$episode_file")
    local duration=$(estimate_duration "$episode_file")

    # 3. 检查文件内容是否为空
    if [ "$word_count" -lt 50 ]; then
        output_json "{
          \"status\": \"error\",
          \"error_code\": \"EMPTY_FILE\",
          \"message\": \"剧本文件内容过少或为空\",
          \"file_info\": {
            \"path\": \"$episode_file\",
            \"word_count\": $word_count
          }
        }"
        exit 1
    fi

    # 4. 判断是否第1集(第1集时长标准不同)
    local is_first_episode=false
    if [ "$episode_num" = "1" ]; then
        is_first_episode=true
    fi

    # 5. 返回成功信息
    output_json "{
      \"status\": \"success\",
      \"project_name\": \"$PROJECT_NAME\",
      \"episode_info\": {
        \"file\": \"$episode_file\",
        \"episode_number\": $episode_num,
        \"is_first_episode\": $is_first_episode,
        \"word_count\": $word_count,
        \"dialogue_count\": $dialogue_count,
        \"duration_estimate\": $duration
      },
      \"standards\": {
        \"duration_min\": $([ "$is_first_episode" = true ] && echo "120" || echo "90"),
        \"duration_max\": $([ "$is_first_episode" = true ] && echo "240" || echo "180"),
        \"dialogue_max\": 5,
        \"forbidden_keywords\": [\"心想\", \"暗道\", \"觉得\", \"想到\", \"你要知道\", \"其实\", \"让我告诉你\", \"然而\", \"因此\"],
        \"required_elements\": {
          \"opening_conflict\": \"前10秒必须抛冲突\",
          \"hook_ending\": \"结尾必须有动作/反转钩子\"
        }
      },
      \"message\": \"准备进行质量检查\",
      \"next_steps\": [
        \"AI将读取完整剧本内容\",
        \"检查时长、对白、开篇、钩子\",
        \"识别禁止内容(心理描写/解释台词)\",
        \"评估口语化和细节\",
        \"生成评分和改进建议\"
      ]
    }"
}

# 主流程
main() {
    if [ "$CHECK_ALL" = true ]; then
        batch_check
    else
        single_check "$@"
    fi
}

# 执行主流程
main "$@"
