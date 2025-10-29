#!/usr/bin/env bash
# 保存项目状态
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
PROJECT_DIR=$(get_current_project "$1")
[ -z "$PROJECT_DIR" ] && output_json "{\"status\": \"error\", \"message\": \"未找到项目\"}" && exit 1
output_json "{\"status\": \"success\", \"message\": \"项目已自动保存\", \"project_name\": \"$(basename "$PROJECT_DIR")\"}"
