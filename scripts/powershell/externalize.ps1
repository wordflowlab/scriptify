# 内心戏外化 - 将心理描写转化为可拍摄内容

# 加载通用函数库
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ScriptDir\common.ps1"

# 获取项目路径
$ProjectDir = Get-CurrentProject
$ProjectName = Get-ProjectName
$ExtractedFile = Join-Path $ProjectDir "extracted.md"
$NovelDir = Join-Path $ProjectDir "novel"
$ExternalizedFile = Join-Path $ProjectDir "externalized.md"

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
                step2 = "然后再运行 /externalize 外化内心戏"
            }
        }
        exit 1
    }

    # 创建外化文件模板
    $Date = Get-Date -Format 'yyyy-MM-dd'
    $Template = @"
# 内心戏外化方案

**提炼日期**: $Date

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
"@

    $Template | Out-File -FilePath $ExternalizedFile -Encoding UTF8

    # 输出结果
    $OriginalFile = Join-Path $NovelDir "original.txt"
    $FilesToRead = @($ExtractedFile)
    if (Test-Path $OriginalFile) {
        $FilesToRead += $OriginalFile
    }

    Output-Json @{
        status = "success"
        project_name = $ProjectName
        extracted_file = $ExtractedFile
        externalized_file = $ExternalizedFile
        message = "已创建外化文件,请AI识别内心戏并提供外化方案"
        ai_task = @{
            instruction = "请扫描提炼的情节,识别所有内心戏并提供外化方案"
            files_to_read = $FilesToRead
            output_file = $ExternalizedFile
            externalization_techniques = @(
                "转化为对话",
                "转化为旁白(os)",
                "转化为动作/表情",
                "转化为闪回/梦境"
            )
        }
    }
}

# 执行主流程
Main
