#!/usr/bin/env bash
# 通用函数库 - Scriptify

# 获取 Scriptify 项目根目录
get_scriptify_root() {
    # 查找包含 .scriptify/config.json 的项目根目录
    if [ -f ".scriptify/config.json" ]; then
        pwd
    else
        # 向上查找包含 .scriptify 的目录
        current=$(pwd)
        while [ "$current" != "/" ]; do
            if [ -f "$current/.scriptify/config.json" ]; then
                echo "$current"
                return 0
            fi
            current=$(dirname "$current")
        done
        echo "错误: 未找到 scriptify 项目根目录" >&2
        echo "提示: 请在 scriptify 项目目录内运行，或先运行 'scriptify init <项目名>' 创建项目" >&2
        exit 1
    fi
}

# 获取用户项目目录
get_projects_dir() {
    SCRIPTIFY_ROOT=$(get_scriptify_root)
    echo "$SCRIPTIFY_ROOT/projects"
}

# 获取当前项目路径（从参数或环境变量）
get_current_project() {
    if [ -n "$1" ]; then
        # 从参数获取项目名
        PROJECTS_DIR=$(get_projects_dir)
        echo "$PROJECTS_DIR/$1"
    elif [ -n "$SCRIPTIFY_PROJECT" ]; then
        # 从环境变量获取
        echo "$SCRIPTIFY_PROJECT"
    else
        # 查找最新的项目
        PROJECTS_DIR=$(get_projects_dir)
        if [ -d "$PROJECTS_DIR" ]; then
            latest=$(ls -t "$PROJECTS_DIR" 2>/dev/null | head -1)
            if [ -n "$latest" ]; then
                echo "$PROJECTS_DIR/$latest"
            fi
        fi
    fi
}

# 获取项目名称
get_project_name() {
    project_dir=$(get_current_project "$@")
    if [ -n "$project_dir" ]; then
        basename "$project_dir"
    fi
}

# 创建带编号的目录
create_numbered_dir() {
    base_dir="$1"
    prefix="$2"

    mkdir -p "$base_dir"

    # 找到最高编号
    highest=0
    for dir in "$base_dir"/*; do
        [ -d "$dir" ] || continue
        dirname=$(basename "$dir")
        number=$(echo "$dirname" | grep -o '^[0-9]\+' || echo "0")
        number=$((10#$number))
        if [ "$number" -gt "$highest" ]; then
            highest=$number
        fi
    done

    # 返回下一个编号
    next=$((highest + 1))
    printf "%03d" "$next"
}

# 输出 JSON（用于与 AI 助手通信）
output_json() {
    echo "$1"
}

# 确保文件存在
ensure_file() {
    file="$1"
    template="$2"

    if [ ! -f "$file" ]; then
        if [ -f "$template" ]; then
            cp "$template" "$file"
        else
            touch "$file"
        fi
    fi
}

# 准确的字数统计（支持剧本格式）
# 排除场景描述、人物名等格式标记，只统计对话和叙述内容
count_script_words() {
    local file="$1"

    if [ ! -f "$file" ]; then
        echo "0"
        return
    fi

    # 统计剧本实际内容字数
    # 保留: 对话内容、场景描述、动作描述
    # 移除: Markdown标记、场次标题、人物名标记
    local word_count=$(cat "$file" | \
        sed '/^```/,/^```/d' | \
        sed 's/^#\+[[:space:]]*//' | \
        sed 's/\*\*//g' | \
        sed 's/__//g' | \
        sed 's/\*//g' | \
        sed 's/_//g' | \
        sed 's/\[//g' | \
        sed 's/\]//g' | \
        sed 's/(http[^)]*)//g' | \
        sed 's/^>[[:space:]]*//' | \
        tr -d '[:space:]' | \
        tr -d '[:punct:]' | \
        grep -o . | \
        wc -l | \
        tr -d ' ')

    echo "$word_count"
}

# 显示友好的字数信息
# 参数: 文件路径, 最小字数(可选), 最大字数(可选)
show_word_count_info() {
    local file="$1"
    local min_words="${2:-0}"
    local max_words="${3:-999999}"
    local actual_words=$(count_script_words "$file")

    echo "字数：$actual_words"

    if [ "$min_words" -gt 0 ]; then
        if [ "$actual_words" -lt "$min_words" ]; then
            echo "⚠️ 未达到最低字数要求（最小：${min_words}）"
        elif [ "$actual_words" -gt "$max_words" ]; then
            echo "⚠️ 超过最大字数限制（最大：${max_words}）"
        else
            echo "✅ 符合字数要求（${min_words}-${max_words}）"
        fi
    fi
}

# 检查项目是否存在
check_project_exists() {
    local project_name="$1"
    local project_dir=$(get_current_project "$project_name")

    if [ -z "$project_dir" ] || [ ! -d "$project_dir" ]; then
        output_json "{\"status\": \"error\", \"message\": \"项目不存在: $project_name\"}"
        exit 1
    fi

    echo "$project_dir"
}

# 检查项目配置文件是否存在
check_project_config() {
    local project_dir="$1"
    local config_file="$project_dir/spec.json"

    if [ ! -f "$config_file" ]; then
        output_json "{\"status\": \"error\", \"message\": \"项目配置文件不存在，请先运行 /spec\"}"
        exit 1
    fi

    echo "$config_file"
}
