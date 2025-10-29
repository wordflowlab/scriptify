#!/usr/bin/env pwsh
# 导入小说 - 智能扫描、格式检测、自动拆分 (PowerShell版本)

# 加载通用函数库
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$scriptDir/common.ps1"

# 配置
$SPLIT_THRESHOLD = 300000  # 30万字以上建议拆分
$MAX_CHAPTER_SIZE = 50000  # 单章最大字数(超过则按字数拆分)

# 获取项目路径
$projectDir = Get-CurrentProject
$projectName = Get-ProjectName
$importDir = Join-Path $projectDir "import"
$novelDir = Join-Path $projectDir "novel"

# 检测文件编码
function Get-FileEncoding {
    param([string]$FilePath)

    try {
        # 读取文件的前几个字节检查BOM
        $bytes = Get-Content -Path $FilePath -Encoding Byte -TotalCount 4

        # UTF-8 BOM: EF BB BF
        if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
            return "utf-8"
        }

        # UTF-16 LE BOM: FF FE
        if ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) {
            return "utf-16le"
        }

        # UTF-16 BE BOM: FE FF
        if ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFE -and $bytes[1] -eq 0xFF) {
            return "utf-16be"
        }

        # 尝试读取内容检测
        $content = Get-Content -Path $FilePath -Encoding UTF8 -ErrorAction SilentlyContinue
        if ($content) {
            # 检查是否有乱码
            $hasGarbage = $content -match '[\uFFFD\u0000-\u001F]'
            if (-not $hasGarbage) {
                return "utf-8"
            }
        }

        # 默认假设GBK
        return "gbk"
    }
    catch {
        return "unknown"
    }
}

# 转换编码到UTF-8
function Convert-ToUtf8 {
    param(
        [string]$InputFile,
        [string]$Encoding,
        [string]$OutputFile
    )

    try {
        if ($Encoding -eq "utf-8" -or $Encoding -eq "us-ascii") {
            Copy-Item $InputFile $OutputFile
        }
        elseif ($Encoding -eq "gbk") {
            # PowerShell中使用GB2312/GBK编码
            $content = Get-Content -Path $InputFile -Encoding Default
            $content | Out-File -FilePath $OutputFile -Encoding UTF8
        }
        else {
            # 尝试默认编码
            $content = Get-Content -Path $InputFile -Encoding Default
            $content | Out-File -FilePath $OutputFile -Encoding UTF8
        }
    }
    catch {
        # 转换失败就直接复制
        Copy-Item $InputFile $OutputFile
    }
}

# 检测章节格式
function Get-ChapterPattern {
    param([string]$FilePath)

    $patterns = @(
        "^第[0-9零一二三四五六七八九十百千]+章",
        "^第[0-9零一二三四五六七八九十百千]+回",
        "^Chapter [0-9]+",
        "^chapter [0-9]+",
        "^[0-9]+\.",
        "^[0-9]+、"
    )

    $bestPattern = "none"
    $maxCount = 0

    foreach ($pattern in $patterns) {
        $content = Get-Content $FilePath
        $count = ($content | Select-String -Pattern $pattern).Count

        if ($count -gt $maxCount) {
            $maxCount = $count
            $bestPattern = $pattern
        }
    }

    if ($maxCount -gt 5) {
        return "$bestPattern|$maxCount"
    }
    else {
        return "none|0"
    }
}

# 清理文本格式
function Clean-Text {
    param(
        [string]$InputFile,
        [string]$OutputFile
    )

    $content = Get-Content $InputFile
    $cleaned = @()

    $blankCount = 0
    foreach ($line in $content) {
        # 去除行首空格
        $line = $line -replace '^\s+', ''
        # 去除尾部空白
        $line = $line -replace '\s+$', ''

        if ([string]::IsNullOrWhiteSpace($line)) {
            $blankCount++
            if ($blankCount -le 1) {
                $cleaned += ""
            }
        }
        else {
            $blankCount = 0
            $cleaned += $line
        }
    }

    $cleaned | Out-File -FilePath $OutputFile -Encoding UTF8
}

# 按章节拆分
function Split-ByChapters {
    param(
        [string]$InputFile,
        [string]$Pattern,
        [string]$OutputDir
    )

    if (-not (Test-Path $OutputDir)) {
        New-Item -ItemType Directory -Path $OutputDir | Out-Null
    }

    # 读取所有内容
    $content = Get-Content $InputFile -Encoding UTF8
    $chapterNum = 0
    $currentChapter = @()
    $currentFile = $null

    foreach ($line in $content) {
        if ($line -match $Pattern) {
            # 保存前一章
            if ($currentFile -and $currentChapter.Count -gt 0) {
                $currentChapter | Out-File -FilePath $currentFile -Encoding UTF8 -NoNewline:$false
            }

            # 开始新章节
            $chapterNum++
            $currentFile = Join-Path $OutputDir ("chapter-{0:D3}.txt" -f $chapterNum)
            $currentChapter = @($line)
        }
        elseif ($currentFile) {
            $currentChapter += $line
        }
    }

    # 保存最后一章
    if ($currentFile -and $currentChapter.Count -gt 0) {
        $currentChapter | Out-File -FilePath $currentFile -Encoding UTF8 -NoNewline:$false
    }

    return $chapterNum
}

# 按字数拆分
function Split-BySize {
    param(
        [string]$InputFile,
        [int]$ChunkSize,
        [string]$OutputDir
    )

    if (-not (Test-Path $OutputDir)) {
        New-Item -ItemType Directory -Path $OutputDir | Out-Null
    }

    $content = Get-Content $InputFile
    $totalWords = Count-ScriptWords -FilePath $InputFile
    $linesPerChunk = [Math]::Max(100, [int]($content.Count * $ChunkSize / $totalWords))

    $partCount = 0
    $currentPart = @()

    for ($i = 0; $i -lt $content.Count; $i++) {
        $currentPart += $content[$i]

        if ($currentPart.Count -ge $linesPerChunk -or $i -eq $content.Count - 1) {
            $partCount++
            $partFile = Join-Path $OutputDir ("chapter-{0:D3}.txt" -f $partCount)
            $currentPart | Out-File -FilePath $partFile -Encoding UTF8
            $currentPart = @()
        }
    }

    return $partCount
}

# 主流程
function Main {
    # 创建必要目录
    if (-not (Test-Path $importDir)) {
        New-Item -ItemType Directory -Path $importDir | Out-Null
    }
    if (-not (Test-Path $novelDir)) {
        New-Item -ItemType Directory -Path $novelDir | Out-Null
    }

    # 1. 扫描 import/ 目录
    $txtFiles = Get-ChildItem -Path $importDir -File -Filter "*.txt"

    if ($txtFiles.Count -eq 0) {
        $error = @{
            status       = "error"
            error_code   = "NO_FILE"
            message      = "未找到待导入的TXT文件"
            guide        = @{
                step1       = "请将下载的小说TXT文件放到以下目录:"
                import_path = $importDir
                step2       = "然后重新运行 /import 命令"
                tip         = "支持UTF-8和GBK编码,系统会自动转换"
            }
        }
        Output-Json $error
        exit 1
    }

    # 如果有多个文件,选择最大的
    $novelFile = $txtFiles | Sort-Object Length -Descending | Select-Object -First 1
    $originalName = $novelFile.Name

    # 2. 检测编码
    $encoding = Get-FileEncoding -FilePath $novelFile.FullName

    # 3. 转换编码并清理格式
    $tempFile = Join-Path $novelDir "temp_converted.txt"
    Convert-ToUtf8 -InputFile $novelFile.FullName -Encoding $encoding -OutputFile $tempFile

    $cleanedFile = Join-Path $novelDir "temp_cleaned.txt"
    Clean-Text -InputFile $tempFile -OutputFile $cleanedFile
    Remove-Item $tempFile -ErrorAction SilentlyContinue

    # 4. 统计字数
    $wordCount = Count-ScriptWords -FilePath $cleanedFile

    # 5. 检测章节结构
    $chapterInfo = Get-ChapterPattern -FilePath $cleanedFile
    $chapterPattern, $chapterCount = $chapterInfo -split '\|'

    # 6. 决定是否拆分
    $shouldSplit = $false
    $splitMethod = "none"
    $actualParts = 0

    if ($wordCount -gt $SPLIT_THRESHOLD) {
        $shouldSplit = $true

        if ($chapterPattern -ne "none" -and [int]$chapterCount -gt 10) {
            # 按章节拆分
            $splitMethod = "chapter"
            $actualParts = Split-ByChapters -InputFile $cleanedFile -Pattern $chapterPattern -OutputDir $novelDir
        }
        else {
            # 按字数拆分
            $splitMethod = "size"
            $actualParts = Split-BySize -InputFile $cleanedFile -ChunkSize $MAX_CHAPTER_SIZE -OutputDir $novelDir
        }
    }

    # 7. 保存原始文件
    $originalFile = Join-Path $novelDir "original.txt"
    Copy-Item $cleanedFile $originalFile
    Remove-Item $cleanedFile -ErrorAction SilentlyContinue

    # 8. 输出结果
    if ($shouldSplit) {
        $result = @{
            status          = "success"
            project_name    = $projectName
            original_file   = $originalName
            encoding        = $encoding
            word_count      = $wordCount
            chapter_pattern = $chapterPattern
            chapter_count   = [int]$chapterCount
            split           = $true
            split_method    = $splitMethod
            parts_count     = $actualParts
            novel_dir       = $novelDir
            files           = @{
                original = "$novelDir/original.txt"
                parts    = "$novelDir/chapter-*.txt"
            }
            message         = "小说已导入并拆分为 $actualParts 个文件"
            recommendations = @(
                "原文较长($wordCount 字),已自动拆分以便处理",
                "完整原文保存在: novel/original.txt",
                "拆分文件保存在: novel/chapter-*.txt",
                "建议先运行 /analyze 分析小说结构"
            )
        }
        Output-Json $result
    }
    else {
        $result = @{
            status          = "success"
            project_name    = $projectName
            original_file   = $originalName
            encoding        = $encoding
            word_count      = $wordCount
            chapter_pattern = $chapterPattern
            chapter_count   = [int]$chapterCount
            split           = $false
            novel_dir       = $novelDir
            files           = @{
                original = "$novelDir/original.txt"
            }
            message         = "小说导入成功"
            recommendations = @(
                "小说已保存到: novel/original.txt",
                "检测到 $chapterCount 个章节",
                "建议先运行 /analyze 分析小说结构"
            )
        }
        Output-Json $result
    }
}

# 执行主流程
Main
