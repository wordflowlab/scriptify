#!/usr/bin/env bash
# 篇幅压缩 - 将冗长内容精简为剧本格式

# 加载通用函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 获取项目路径
PROJECT_DIR=$(get_current_project)
PROJECT_NAME=$(get_project_name)
EXTRACTED_FILE="$PROJECT_DIR/extracted.md"
COMPRESSED_FILE="$PROJECT_DIR/compressed.md"

# 主流程
main() {
    # 检查是否已有提炼文件
    if [ ! -f "$EXTRACTED_FILE" ]; then
        output_json "{
          \"status\": \"error\",
          \"error_code\": \"NO_EXTRACTED\",
          \"message\": \"未找到提炼文件,请先运行 /extract\",
          \"guide\": {
            \"step1\": \"先运行 /extract 提炼核心情节\",
            \"step2\": \"然后再运行 /compress 压缩篇幅\"
          }
        }"
        exit 1
    fi

    # 统计提炼文件字数
    local extracted_words=$(count_script_words "$EXTRACTED_FILE")

    # 创建压缩文件模板
    cat > "$COMPRESSED_FILE" << EOF
# 篇幅压缩版本

**压缩日期**: $(date '+%Y-%m-%d')
**压缩策略**: 场景合并、对话精简、描写简化、蒙太奇、信息前置

---

## 压缩统计

**提炼版字数**: $extracted_words 字
**压缩目标**: [待AI根据集数计算]
**压缩比例**: [待AI计算]

---

## 压缩技术应用

- 场景合并: [待AI统计]
- 对话精简: [待AI统计]
- 描写简化: [待AI统计]
- 蒙太奇: [待AI统计]
- 信息前置: [待AI统计]

---

## 逐集压缩内容

### 第1集: [标题]

**压缩前**: XXXX字
**压缩后**: 2000字
**压缩比例**: XX%

#### 场景1: [场景名] - [时间] - [内外]
时长: X分钟

[待AI填充简洁的剧本格式内容...]

---

## 删减内容清单

### 完全删除
[待AI列出...]

### 大幅压缩
[待AI列出...]

---

## 下一步

1. 运行 /externalize 外化内心戏
2. 运行 /visualize 确保可拍摄
3. 运行 /script 生成最终剧本
EOF

    # 输出结果
    output_json "{
      \"status\": \"success\",
      \"project_name\": \"$PROJECT_NAME\",
      \"extracted_file\": \"$EXTRACTED_FILE\",
      \"extracted_words\": $extracted_words,
      \"compressed_file\": \"$COMPRESSED_FILE\",
      \"message\": \"已创建压缩文件,请AI应用压缩技术精简内容\",
      \"ai_task\": {
        \"instruction\": \"请应用五大压缩技术,将提炼内容精简为剧本格式\",
        \"files_to_read\": [
          \"$EXTRACTED_FILE\"
        ],
        \"output_file\": \"$COMPRESSED_FILE\",
        \"compression_techniques\": [
          \"场景合并\",
          \"对话精简\",
          \"描写简化\",
          \"蒙太奇压缩\",
          \"信息前置\"
        ],
        \"principles\": [
          \"保持故事完整性\",
          \"突出核心冲突\",
          \"节奏紧凑\",
          \"每个场景都有目的\"
        ]
      }
    }"
}

# 执行主流程
main "$@"
