# 提炼核心情节 - 按目标集数分配内容

# 加载通用函数库
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ScriptDir\common.ps1"

# 获取项目路径
$ProjectDir = Get-CurrentProject
$ProjectName = Get-ProjectName
$AnalysisFile = Join-Path $ProjectDir "analysis.md"
$NovelDir = Join-Path $ProjectDir "novel"
$OriginalFile = Join-Path $NovelDir "original.txt"
$ExtractedFile = Join-Path $ProjectDir "extracted.md"

# 参数解析
param(
    [string]$Episodes = "",
    [string]$Duration = "10"  # 默认每集10分钟
)

# 主流程
function Main {
    # 检查是否已有分析文件
    if (!(Test-Path $AnalysisFile)) {
        Output-Json @{
            status = "error"
            error_code = "NO_ANALYSIS"
            message = "未找到分析文件,请先运行 /analyze"
            guide = @{
                step1 = "先运行 /analyze 分析小说结构"
                step2 = "然后再运行 /extract 提炼情节"
            }
        }
        exit 1
    }

    # 检查小说文件
    if (!(Test-Path $OriginalFile)) {
        Output-Json @{
            status = "error"
            error_code = "NO_NOVEL"
            message = "未找到小说文件"
        }
        exit 1
    }

    # 统计信息
    $WordCount = Count-ScriptWords $OriginalFile

    # 计算目标字数(每分钟约200字剧本)
    $TargetWords = 0
    if ($Episodes -ne "") {
        $TargetWords = [int]$Episodes * [int]$Duration * 200
    }

    # 计算删减比例
    $ReductionRate = 0
    if ($TargetWords -gt 0 -and $WordCount -gt 0) {
        $ReductionRate = [math]::Round((($WordCount - $TargetWords) / $WordCount * 100), 1)
    }

    # 创建提炼文件模板
    $Date = Get-Date -Format 'yyyy-MM-dd'
    $Template = @"
# 核心情节提炼与分集大纲

**原小说**: $ProjectName
**原小说字数**: $WordCount 字
**改编目标**: ${Episodes}集 × ${Duration}分钟
**目标字数**: 约 $TargetWords 字
**删减比例**: 约 ${ReductionRate}%
**提炼日期**: $Date

---

## 改编策略

### 删减比例

[待AI填充...]

### 保留重点

[待AI根据分析文件确定...]

### 删减内容

[待AI列出删减的支线和内容...]

---

## 分集大纲

### 第一幕 (第X-X集)

[待AI分配...]

#### 第1集: [标题]

**核心事件**: [待AI填充]
**对应原文**: 第X-X章
**Hook**: [开场抓人点]
**转折**: [本集转折]
**悬念**: [结尾悬念]
**本集冲突**: [主要冲突]
**字数**: 约XXX字

[继续为每集分配...]

---

## 下一步

1. 运行 /compress 进一步压缩篇幅
2. 运行 /visualize 将文字转为可拍摄场景
3. 运行 /externalize 外化内心戏
4. 最终运行 /script 生成剧本
"@

    $Template | Out-File -FilePath $ExtractedFile -Encoding UTF8

    # 输出结果
    Output-Json @{
        status = "success"
        project_name = $ProjectName
        novel_info = @{
            word_count = $WordCount
            original_file = $OriginalFile
        }
        target = @{
            episodes = if ($Episodes -ne "") { [int]$Episodes } else { 0 }
            duration = [int]$Duration
            target_words = $TargetWords
            reduction_rate = "${ReductionRate}%"
        }
        analysis_file = $AnalysisFile
        extracted_file = $ExtractedFile
        message = "已创建提炼文件,请AI根据分析结果分配情节"
        ai_task = @{
            instruction = "请根据分析文件和小说内容,提炼核心情节并按集数分配"
            files_to_read = @($AnalysisFile, $OriginalFile)
            output_file = $ExtractedFile
            requirements = @(
                "为每集分配核心事件",
                "标注Hook和转折点",
                "设置集与集的悬念连接",
                "列出删减的内容",
                "确保三幕结构合理"
            )
        }
    }
}

# 执行主流程
Main
