# 保存当前工作进度

# 加载通用函数
. "$PSScriptRoot\common.ps1"

# 获取项目路径
$projectDir = Get-CurrentProject
$projectName = Get-ProjectName

$progressFile = Join-Path $projectDir ".scriptify" "progress.json"

# 检测当前正在进行的工作
function Detect-CurrentWork {
    $outlineFile = Join-Path $projectDir "outline.md"
    $charactersFile = Join-Path $projectDir "characters.md"

    # 检查 outline.md
    if (Test-Path $outlineFile) {
        # 检查是否完整(是否包含所有 12 个节拍)
        $beatCount = (Select-String -Path $outlineFile -Pattern "^###" -AllMatches).Matches.Count
        if ($beatCount -lt 12) {
            return "outline"
        }
    }

    # 检查 characters.md
    if (Test-Path $charactersFile) {
        $lineCount = (Get-Content $charactersFile).Count
        if ($lineCount -lt 20) {
            return "characters"
        }
    }

    return "none"
}

# 分析 outline.md 的进度
function Analyze-OutlineProgress {
    $outlineFile = Join-Path $projectDir "outline.md"

    if (-not (Test-Path $outlineFile)) {
        return @{}
    }

    $beatNames = @("opening", "inciting", "act1turn", "bstory", "fun", "midpoint", "badguys", "allislost", "darknight", "breakinto3", "climax", "finale")
    $beatTitles = @("开场画面", "激励事件", "第一幕转折点", "B 故事线", "娱乐时刻", "中点", "坏人逼近", "低谷时刻", "灵魂暗夜", "顿悟", "决战", "结局画面")

    $completedBeats = @()
    $currentBeat = ""
    $nextBeat = ""

    $content = Get-Content $outlineFile -Raw

    for ($i = 0; $i -lt $beatTitles.Count; $i++) {
        if ($content -match "### $($beatTitles[$i])") {
            $completedBeats += $beatNames[$i]
        } else {
            if (-not $currentBeat) {
                $currentBeat = $beatNames[$i]
                if ($i -lt ($beatNames.Count - 1)) {
                    $nextBeat = $beatNames[$i + 1]
                }
            }
            break
        }
    }

    $status = "in_progress"
    if ($completedBeats.Count -eq 12) {
        $status = "completed"
        $currentBeat = ""
        $nextBeat = ""
    } elseif ($completedBeats.Count -eq 0) {
        $status = "not_started"
        $currentBeat = "opening"
        $nextBeat = "inciting"
    }

    return @{
        status = $status
        completed_beats = $completedBeats
        current_beat = $currentBeat
        next_beat = $nextBeat
        total_beats = 12
        completed_count = $completedBeats.Count
    }
}

# 列出已存在的文件
function List-ExistingFiles {
    $files = @()
    foreach ($file in @("spec.json", "idea.md", "outline.md", "characters.md")) {
        $filePath = Join-Path $projectDir $file
        if (Test-Path $filePath) {
            $files += $file
        }
    }
    return $files
}

# 主逻辑
$currentWork = Detect-CurrentWork
$existingFiles = List-ExistingFiles

$result = @{
    status = "success"
    current_work = $currentWork
    existing_files = $existingFiles
    project_name = $projectName
    project_path = $projectDir
    progress_file = $progressFile
}

if ($currentWork -eq "outline") {
    $progressInfo = Analyze-OutlineProgress
    $result.progress_info = $progressInfo
} elseif ($currentWork -eq "characters") {
    $result.progress_info = @{
        status = "in_progress"
    }
} else {
    $result.progress_info = @{}
}

# 输出 JSON
Output-Json $result
