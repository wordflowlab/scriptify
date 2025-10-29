#!/usr/bin/env bash
# 保存当前工作进度

# 加载通用函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 获取项目路径
PROJECT_DIR=$(get_current_project)
PROJECT_NAME=$(get_project_name)

PROGRESS_FILE="$PROJECT_DIR/.scriptify/progress.json"

# 检测当前正在进行的工作
detect_current_work() {
    local outline_file="$PROJECT_DIR/outline.md"
    local characters_file="$PROJECT_DIR/characters.md"
    local scene_dir="$PROJECT_DIR/scenes"

    # 检查 outline.md
    if [ -f "$outline_file" ]; then
        # 检查是否完整(是否包含所有 12 个节拍)
        local beat_count=$(grep -c "^###" "$outline_file" 2>/dev/null || echo "0")
        if [ "$beat_count" -lt 12 ]; then
            # outline 未完成
            echo "outline"
            return
        fi
    fi

    # 检查 characters.md
    if [ -f "$characters_file" ]; then
        # 简单判断:如果文件很短,可能未完成
        local line_count=$(wc -l < "$characters_file")
        if [ "$line_count" -lt 20 ]; then
            echo "characters"
            return
        fi
    fi

    # 没有正在进行的工作
    echo "none"
}

# 分析 outline.md 的进度
analyze_outline_progress() {
    local outline_file="$PROJECT_DIR/outline.md"

    if [ ! -f "$outline_file" ]; then
        echo "{}"
        return
    fi

    # 提取已完成的节拍
    # 节拍标题格式: ### 开场画面 (0%)
    local beats=()
    local beat_names=("opening" "inciting" "act1turn" "bstory" "fun" "midpoint" "badguys" "allislost" "darknight" "breakinto3" "climax" "finale")
    local beat_titles=("开场画面" "激励事件" "第一幕转折点" "B 故事线" "娱乐时刻" "中点" "坏人逼近" "低谷时刻" "灵魂暗夜" "顿悟" "决战" "结局画面")

    local completed_beats="["
    local current_beat=""
    local next_beat=""

    local found_count=0
    for i in "${!beat_titles[@]}"; do
        if grep -q "### ${beat_titles[$i]}" "$outline_file"; then
            if [ $found_count -gt 0 ]; then
                completed_beats+=", "
            fi
            completed_beats+="\"${beat_names[$i]}\""
            found_count=$((found_count + 1))
        else
            # 第一个未找到的节拍就是当前/下一个
            if [ -z "$current_beat" ]; then
                current_beat="${beat_names[$i]}"
                if [ $i -lt $((${#beat_names[@]} - 1)) ]; then
                    next_beat="${beat_names[$((i + 1))]}"
                fi
            fi
            break
        fi
    done
    completed_beats+="]"

    # 判断状态
    local status="in_progress"
    if [ $found_count -eq 12 ]; then
        status="completed"
        current_beat=""
        next_beat=""
    elif [ $found_count -eq 0 ]; then
        status="not_started"
        current_beat="opening"
        next_beat="inciting"
    fi

    # 构建 JSON
    cat <<EOF
{
  "status": "$status",
  "completed_beats": $completed_beats,
  "current_beat": "$current_beat",
  "next_beat": "$next_beat",
  "total_beats": 12,
  "completed_count": $found_count
}
EOF
}

# 列出已存在的文件
list_existing_files() {
    local files="["
    local first=true

    for file in "spec.json" "idea.md" "outline.md" "characters.md"; do
        if [ -f "$PROJECT_DIR/$file" ]; then
            if [ "$first" = false ]; then
                files+=", "
            fi
            files+="\"$file\""
            first=false
        fi
    done

    files+="]"
    echo "$files"
}

# 主逻辑
current_work=$(detect_current_work)
existing_files=$(list_existing_files)

if [ "$current_work" = "outline" ]; then
    # 分析 outline 进度
    progress_info=$(analyze_outline_progress)

    output_json "{
      \"status\": \"success\",
      \"current_work\": \"outline\",
      \"progress_info\": $progress_info,
      \"existing_files\": $existing_files,
      \"project_name\": \"$PROJECT_NAME\",
      \"project_path\": \"$PROJECT_DIR\",
      \"progress_file\": \"$PROGRESS_FILE\"
    }"
elif [ "$current_work" = "characters" ]; then
    output_json "{
      \"status\": \"success\",
      \"current_work\": \"characters\",
      \"progress_info\": {
        \"status\": \"in_progress\"
      },
      \"existing_files\": $existing_files,
      \"project_name\": \"$PROJECT_NAME\",
      \"project_path\": \"$PROJECT_DIR\",
      \"progress_file\": \"$PROGRESS_FILE\"
    }"
else
    # 没有正在进行的工作
    output_json "{
      \"status\": \"success\",
      \"current_work\": \"none\",
      \"progress_info\": {},
      \"existing_files\": $existing_files,
      \"project_name\": \"$PROJECT_NAME\",
      \"project_path\": \"$PROJECT_DIR\",
      \"progress_file\": \"$PROGRESS_FILE\"
    }"
fi
