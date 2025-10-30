#!/usr/bin/env bash
# 内心戏外化 - 将心理描写转化为可拍摄内容

# 加载通用函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 获取项目路径
PROJECT_DIR=$(get_current_project)
PROJECT_NAME=$(get_project_name)
EXTRACTED_FILE="$PROJECT_DIR/extracted.md"
NOVEL_DIR="$PROJECT_DIR/novel"
EXTERNALIZED_FILE="$PROJECT_DIR/externalized.md"

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
            \"step2\": \"然后再运行 /externalize 外化内心戏\"
          }
        }"
        exit 1
    fi

    # 创建外化文件模板
    cat > "$EXTERNALIZED_FILE" << EOF
# 内心戏外化方案

**提炼日期**: $(date '+%Y-%m-%d')

---

## 外化统计

- 原始内心戏数量: [待AI统计]
- 转为对话: [待AI统计]
- 转为旁白(os): [待AI统计]
- 转为动作: [待AI统计]
- 转为闪回: [待AI统计]

---

## 逐集外化方案

### 第1集

[待AI填充每个内心戏的外化方案...]

---

## 外化原则总结

1. 优先对话 (30-40%)
2. 其次动作 (30-40%)
3. 适度闪回 (15-20%)
4. 慎用旁白 (5-10%)

---

## 下一步

1. 运行 /visualize 确保所有场景可拍摄
2. 运行 /script 生成最终剧本
EOF

    # 输出结果
    output_json "{
      \"status\": \"success\",
      \"project_name\": \"$PROJECT_NAME\",
      \"extracted_file\": \"$EXTRACTED_FILE\",
      \"externalized_file\": \"$EXTERNALIZED_FILE\",
      \"message\": \"已创建外化文件,请AI识别内心戏并提供外化方案\",
      \"ai_task\": {
        \"instruction\": \"请扫描提炼的情节,识别所有内心戏并提供外化方案\",
        \"files_to_read\": [
          \"$EXTRACTED_FILE\",
          \"$NOVEL_DIR/original.txt\"
        ],
        \"output_file\": \"$EXTERNALIZED_FILE\",
        \"externalization_techniques\": [
          \"转化为对话\",
          \"转化为旁白(os)\",
          \"转化为动作/表情\",
          \"转化为闪回/梦境\"
        ]
      }
    }"
}

# 执行主流程
main "$@"
