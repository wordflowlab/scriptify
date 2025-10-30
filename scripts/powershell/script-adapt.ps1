# 生成标准剧本格式(用于小说改编流程)

# 加载通用函数库
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ScriptDir\common.ps1"

# 获取项目路径
$ProjectDir = Get-CurrentProject
$ProjectName = Get-ProjectName
$CompressedFile = Join-Path $ProjectDir "compressed.md"
$ExternalizedFile = Join-Path $ProjectDir "externalized.md"
$VisualizedFile = Join-Path $ProjectDir "visualized.md"
$ScriptsDir = Join-Path $ProjectDir "scripts"

# 参数解析
param(
    [string]$Episode = ""
)

# 主流程
function Main {
    # 检查是否已有必要的改编材料
    $MissingFiles = @()

    if (!(Test-Path $CompressedFile)) {
        $MissingFiles += "compressed.md (运行 /compress)"
    }

    # externalized.md 和 visualized.md 是可选的
    $HasExternalized = Test-Path $ExternalizedFile
    $HasVisualized = Test-Path $VisualizedFile

    # 如果缺少必要文件,报错
    if ($MissingFiles.Count -gt 0) {
        $MissingList = $MissingFiles | ConvertTo-Json

        Output-Json @{
            status = "error"
            error_code = "MISSING_FILES"
            message = "缺少必要的改编材料"
            missing_files = $MissingFiles
            guide = @{
                step1 = "先运行 /compress 压缩篇幅"
                step2 = "(可选) 运行 /externalize 外化内心戏"
                step3 = "(可选) 运行 /visualize 视觉化场景"
                step4 = "然后运行 /script 生成剧本"
            }
        }
        exit 1
    }

    # 创建scripts目录
    if (!(Test-Path $ScriptsDir)) {
        New-Item -ItemType Directory -Path $ScriptsDir | Out-Null
    }

    # 统计字数
    $CompressedWords = Count-ScriptWords $CompressedFile

    # 确定要生成的剧本文件
    $ScriptFile = ""
    $EpisodeInfo = "所有集数"

    if ($Episode -ne "") {
        $ScriptFile = Join-Path $ScriptsDir "episode-$Episode.md"
        $EpisodeInfo = "第${Episode}集"
    } else {
        $ScriptFile = Join-Path $ScriptsDir "full-script.md"
    }

    # 检查是否已存在
    if (Test-Path $ScriptFile) {
        $ExistingWords = Count-ScriptWords $ScriptFile

        $FilesAvailable = @{
            compressed = $CompressedFile
            externalized = if ($HasExternalized) { $ExternalizedFile } else { $null }
            visualized = if ($HasVisualized) { $VisualizedFile } else { $null }
        }

        Output-Json @{
            status = "success"
            action = "review"
            project_name = $ProjectName
            episode = $EpisodeInfo
            script_file = $ScriptFile
            existing_words = $ExistingWords
            message = "已存在剧本文件,可以继续优化"
            files_available = $FilesAvailable
        }
    } else {
        # 创建剧本文件模板
        $Title = if ($Episode -ne "") { "第${Episode}集" } else { "完整剧本" }
        $EpisodeLine = if ($Episode -ne "") { "**集数**: 第${Episode}集" } else { "" }

        $Template = @"
# $Title

**项目**: $ProjectName
**创建日期**: $(Get-Date -Format 'yyyy-MM-dd')
**编剧**: AI
$EpisodeLine

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
"@

        $Template | Out-File -FilePath $ScriptFile -Encoding UTF8

        # 构建files_to_read数组
        $FilesToRead = @($CompressedFile)
        if ($HasExternalized) {
            $FilesToRead += $ExternalizedFile
        }
        if ($HasVisualized) {
            $FilesToRead += $VisualizedFile
        }

        Output-Json @{
            status = "success"
            action = "create"
            project_name = $ProjectName
            episode = $EpisodeInfo
            script_file = $ScriptFile
            compressed_words = $CompressedWords
            message = "已创建剧本文件,请AI根据改编材料编写标准剧本"
            ai_task = @{
                instruction = "请根据所有改编材料,编写符合标准格式的剧本"
                files_to_read = $FilesToRead
                output_file = $ScriptFile
                format_requirements = @(
                    "场景标题: 地点 - 时间 - 内/外",
                    "场景描述: 简洁、具体、可拍摄",
                    "对话格式: 角色名 + (情绪) + 对白",
                    "使用△标记重要视觉元素",
                    "每个场景都有明确冲突",
                    "每集2000字左右,10分钟时长"
                )
                principles = @(
                    "严格遵循剧本格式",
                    "无心理描写",
                    "对话精炼有力",
                    "场景描述可拍摄",
                    "每集有Hook和悬念结尾"
                )
            }
        }
    }
}

# 执行主流程
Main
