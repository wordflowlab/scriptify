#!/usr/bin/env bash
# 生成标准剧本格式(用于小说改编流程)

# 加载通用函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 获取项目路径
PROJECT_DIR=$(get_current_project)
PROJECT_NAME=$(get_project_name)
COMPRESSED_FILE="$PROJECT_DIR/compressed.md"
EXTERNALIZED_FILE="$PROJECT_DIR/externalized.md"
VISUALIZED_FILE="$PROJECT_DIR/visualized.md"
SCRIPTS_DIR="$PROJECT_DIR/scripts"

# 参数解析
EPISODE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --episode)
            EPISODE="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

# 主流程
main() {
    # 检查是否已有必要的改编材料
    local missing_files=()

    if [ ! -f "$COMPRESSED_FILE" ]; then
        missing_files+=("compressed.md (运行 /compress)")
    fi

    # externalized.md 和 visualized.md 是可选的
    local has_externalized=false
    local has_visualized=false

    if [ -f "$EXTERNALIZED_FILE" ]; then
        has_externalized=true
    fi

    if [ -f "$VISUALIZED_FILE" ]; then
        has_visualized=true
    fi

    # 如果缺少必要文件,报错
    if [ ${#missing_files[@]} -gt 0 ]; then
        local missing_list=$(printf ',"%s"' "${missing_files[@]}")
        missing_list="[${missing_list:1}]"

        output_json "{
          \"status\": \"error\",
          \"error_code\": \"MISSING_FILES\",
          \"message\": \"缺少必要的改编材料\",
          \"missing_files\": $missing_list,
          \"guide\": {
            \"step1\": \"先运行 /compress 压缩篇幅\",
            \"step2\": \"(可选) 运行 /externalize 外化内心戏\",
            \"step3\": \"(可选) 运行 /visualize 视觉化场景\",
            \"step4\": \"然后运行 /script 生成剧本\"
          }
        }"
        exit 1
    fi

    # 创建scripts目录
    mkdir -p "$SCRIPTS_DIR"

    # 统计字数
    local compressed_words=$(count_script_words "$COMPRESSED_FILE")

    # 确定要生成的剧本文件
    local script_file=""
    local episode_info="所有集数"

    if [ -n "$EPISODE" ]; then
        script_file="$SCRIPTS_DIR/episode-$EPISODE.md"
        episode_info="第${EPISODE}集"
    else
        script_file="$SCRIPTS_DIR/full-script.md"
    fi

    # 检查是否已存在
    if [ -f "$script_file" ]; then
        local existing_words=$(count_script_words "$script_file")

        output_json "{
          \"status\": \"success\",
          \"action\": \"review\",
          \"project_name\": \"$PROJECT_NAME\",
          \"episode\": \"$episode_info\",
          \"script_file\": \"$script_file\",
          \"existing_words\": $existing_words,
          \"message\": \"已存在剧本文件,可以继续优化\",
          \"files_available\": {
            \"compressed\": \"$COMPRESSED_FILE\",
            \"externalized\": $([ "$has_externalized" = true ] && echo "\"$EXTERNALIZED_FILE\"" || echo "null"),
            \"visualized\": $([ "$has_visualized" = true ] && echo "\"$VISUALIZED_FILE\"" || echo "null")
          }
        }"
    else
        # 创建剧本文件模板
        cat > "$script_file" << 'TEMPLATE'
# 第X集

**项目**: PROJECT_NAME
**创建日期**: DATE
**编剧**: AI

---

## 场景清单

[待AI根据改编材料生成...]

---

## 剧本正文

### 场景1: [场景标题]

[待AI填充标准剧本格式内容...]

---

## 本集统计

- 场景数: [待AI统计]
- 对话轮次: [待AI统计]
- 关键冲突: [待AI统计]
- 字数: [待AI统计]

---

## 创作说明

[待AI记录创作思路和注意事项...]
TEMPLATE

        # 替换模板中的占位符
        if [ -n "$EPISODE" ]; then
            sed -i '' "s/第X集/第${EPISODE}集/" "$script_file"
            sed -i '' "s/\*\*集数\*\*:.*/**集数**: 第${EPISODE}集/" "$script_file"
        else
            sed -i '' "s/第X集/完整剧本/" "$script_file"
        fi
        sed -i '' "s/PROJECT_NAME/$PROJECT_NAME/" "$script_file"
        sed -i '' "s/DATE/$(date '+%Y-%m-%d')/" "$script_file"

        # 构建files_to_read数组
        local files_json="[\"$COMPRESSED_FILE\""
        if [ "$has_externalized" = true ]; then
            files_json="$files_json,\"$EXTERNALIZED_FILE\""
        fi
        if [ "$has_visualized" = true ]; then
            files_json="$files_json,\"$VISUALIZED_FILE\""
        fi
        files_json="$files_json]"

        output_json "{
          \"status\": \"success\",
          \"action\": \"create\",
          \"project_name\": \"$PROJECT_NAME\",
          \"episode\": \"$episode_info\",
          \"script_file\": \"$script_file\",
          \"compressed_words\": $compressed_words,
          \"message\": \"已创建剧本文件,请AI根据改编材料编写标准剧本\",
          \"ai_task\": {
            \"instruction\": \"请根据所有改编材料,编写符合标准格式的剧本\",
            \"files_to_read\": $files_json,
            \"output_file\": \"$script_file\",
            \"format_requirements\": [
              \"场景标题: 地点 - 时间 - 内/外\",
              \"场景描述: 简洁、具体、可拍摄\",
              \"对话格式: 角色名 + (情绪) + 对白\",
              \"使用△标记重要视觉元素\",
              \"每个场景都有明确冲突\",
              \"每集2000字左右,10分钟时长\"
            ],
            \"principles\": [
              \"严格遵循剧本格式\",
              \"无心理描写\",
              \"对话精炼有力\",
              \"场景描述可拍摄\",
              \"每集有Hook和悬念结尾\"
            ]
          }
        }"
    fi
}

# 执行主流程
main "$@"
