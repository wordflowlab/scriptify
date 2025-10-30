# 结构分析 - 分析小说的三幕结构和主要情节

# 加载通用函数库
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ScriptDir\common.ps1"

# 获取项目路径
$ProjectDir = Get-CurrentProject
$ProjectName = Get-ProjectName
$AnalysisFile = Join-Path $ProjectDir "analysis.md"
$NovelDir = Join-Path $ProjectDir "novel"
$OriginalFile = Join-Path $NovelDir "original.txt"

# 主流程
function Main {
    # 检查小说文件是否存在
    if (!(Test-Path $OriginalFile)) {
        Output-Json @{
            status = "error"
            error_code = "NO_NOVEL"
            message = "未找到小说文件,请先运行 /import"
            guide = @{
                step1 = "先运行 /import 导入小说"
                step2 = "然后再运行 /analyze 分析结构"
            }
        }
        exit 1
    }

    # 统计小说字数
    $WordCount = Count-ScriptWords $OriginalFile

    # 统计章节数
    $ChapterCount = 0
    if (Test-Path (Join-Path $NovelDir "chapter-*.txt")) {
        $ChapterCount = (Get-ChildItem (Join-Path $NovelDir "chapter-*.txt")).Count
    }

    # 检查是否已有分析文件
    if (Test-Path $AnalysisFile) {
        $ExistingAnalysis = Get-Content $AnalysisFile -Raw -Encoding UTF8

        Output-Json @{
            status = "success"
            action = "review"
            project_name = $ProjectName
            analysis_file = $AnalysisFile
            novel_file = $OriginalFile
            word_count = $WordCount
            chapter_count = $ChapterCount
            existing_analysis = $ExistingAnalysis
            message = "已存在分析文件,可以继续优化"
        }
    } else {
        # 创建分析文件模板
        $Date = Get-Date -Format 'yyyy-MM-dd'
        $Template = @"
# 小说结构分析

**原小说**: $ProjectName
**字数**: $WordCount 字
**章节数**: $ChapterCount 章
**分析日期**: $Date

---

## 六维分析

### 1. 主线情节
[待AI分析...]

### 2. 三幕结构
[待AI识别...]

### 3. 支线情节
[待AI列出...]

### 4. 关键情节点
[待AI标注...]

### 5. 人物关系
[待AI梳理...]

### 6. 改编难度评估
[待AI评估...]

---

## 下一步

1. 运行 /extract --episodes X 提炼核心情节
2. 运行 /compress 压缩篇幅
3. 运行 /visualize 视觉化场景
"@

        $Template | Out-File -FilePath $AnalysisFile -Encoding UTF8

        Output-Json @{
            status = "success"
            action = "create"
            project_name = $ProjectName
            analysis_file = $AnalysisFile
            novel_file = $OriginalFile
            word_count = $WordCount
            chapter_count = $ChapterCount
            message = "已创建分析文件,请AI根据小说内容完成结构分析"
            ai_task = @{
                instruction = "请阅读小说内容,完成六维结构分析"
                files_to_read = @($OriginalFile)
                output_file = $AnalysisFile
                analysis_dimensions = @(
                    "主线情节",
                    "三幕结构",
                    "支线情节",
                    "关键情节点",
                    "人物关系",
                    "改编难度"
                )
            }
        }
    }
}

# 执行主流程
Main
