#!/usr/bin/env bash
# 导出评估报告
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
PROJECT_DIR=$(get_current_project "$1")
[ -z "$PROJECT_DIR" ] && output_json "{\"status\": \"error\", \"message\": \"未找到项目\"}" && exit 1
output_json "{\"status\": \"success\", \"message\": \"评估报告导出功能开发中\", \"project_name\": \"$(basename "$PROJECT_DIR")\"}"
