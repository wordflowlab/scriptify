# 篇幅压缩 - 将冗长内容精简为剧本格式

# 加载通用函数库
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ScriptDir\common.ps1"

# 获取项目路径
$ProjectDir = Get-CurrentProject
$ProjectName = Get-ProjectName
$ExtractedFile = Join-Path $ProjectDir "extracted.md"
$CompressedFile = Join-Path $ProjectDir "compressed.md"

# 主流程
function Main {
    # 检查是否已有提炼文件
    if (!(Test-Path $ExtractedFile)) {
        Output-Json @{
            status = "error"
            error_code = "NO_EXTRACTED"
            message = "未找到提炼文件,请先运行 /extract"
            guide = @{
                step1 = "先运行 /extract 提炼核心情节"
                step2 = "然后再运行 /compress 压缩篇幅"
            }
        }
        exit 1
    }

    # 统计提炼文件字数
    $ExtractedWords = Count-ScriptWords $ExtractedFile

    # 创建压缩文件模板
    $Date = Get-Date -Format 'yyyy-MM-dd'
    $Template = @"
# 篇幅压缩版本

**压缩日期**: $Date
**压缩策略**: 场景合并、对话精简、描写简化、蒙太奇、信息前置

---

## 压缩统计

**提炼版字数**: $ExtractedWords 字
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
"@

    $Template | Out-File -FilePath $CompressedFile -Encoding UTF8

    # 输出结果
    Output-Json @{
        status = "success"
        project_name = $ProjectName
        extracted_file = $ExtractedFile
        extracted_words = $ExtractedWords
        compressed_file = $CompressedFile
        message = "已创建压缩文件,请AI应用压缩技术精简内容"
        ai_task = @{
            instruction = "请应用五大压缩技术,将提炼内容精简为剧本格式"
            files_to_read = @($ExtractedFile)
            output_file = $CompressedFile
            compression_techniques = @(
                "场景合并",
                "对话精简",
                "描写简化",
                "蒙太奇压缩",
                "信息前置"
            )
            principles = @(
                "保持故事完整性",
                "突出核心冲突",
                "节奏紧凑",
                "每个场景都有目的"
            )
        }
    }
}

# 执行主流程
Main
