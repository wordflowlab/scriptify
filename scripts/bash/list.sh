#!/usr/bin/env bash
# 列出所有剧本项目

# 加载通用函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

PROJECTS_DIR=$(get_projects_dir)

# 检查项目目录是否存在
if [ ! -d "$PROJECTS_DIR" ]; then
    output_json "{\"status\": \"success\", \"projects\": [], \"message\": \"暂无项目，使用 /new 创建第一个项目\"}"
    exit 0
fi

# 获取所有项目
projects=()
for dir in "$PROJECTS_DIR"/*; do
    if [ -d "$dir" ]; then
        project_name=$(basename "$dir")

        # 读取项目信息
        spec_file="$dir/spec.json"
        if [ -f "$spec_file" ]; then
            # 提取项目类型和状态
            type=$(grep -o '"type": *"[^"]*"' "$spec_file" | cut -d'"' -f4)
            stage="已配置"
        else
            type="未设置"
            stage="初始化"
        fi

        # 获取最后修改时间
        modified=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$dir" 2>/dev/null || stat -c "%y" "$dir" | cut -d' ' -f1,2 | cut -d'.' -f1)

        projects+=("{\"name\": \"$project_name\", \"type\": \"$type\", \"stage\": \"$stage\", \"modified\": \"$modified\"}")
    fi
done

# 输出JSON
if [ ${#projects[@]} -eq 0 ]; then
    output_json "{\"status\": \"success\", \"projects\": [], \"message\": \"暂无项目\"}"
else
    projects_json=$(IFS=,; echo "${projects[*]}")
    output_json "{\"status\": \"success\", \"projects\": [$projects_json]}"
fi
