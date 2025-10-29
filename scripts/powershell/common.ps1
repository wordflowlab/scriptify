# 通用函数库 - Scriptify (PowerShell)

# 获取 Scriptify 项目根目录
function Get-ScriptifyRoot {
    # 查找包含 .scriptify/config.json 的项目根目录
    if (Test-Path ".scriptify/config.json") {
        return Get-Location
    }

    # 向上查找包含 .scriptify 的目录
    $current = Get-Location
    while ($current.Path -ne $current.Root.Path) {
        $configPath = Join-Path $current ".scriptify/config.json"
        if (Test-Path $configPath) {
            return $current
        }
        $current = Split-Path $current -Parent
    }

    Write-Error "错误: 未找到 scriptify 项目根目录"
    Write-Error "提示: 请在 scriptify 项目目录内运行，或先运行 'scriptify init <项目名>' 创建项目"
    exit 1
}

# 获取当前剧本项目目录（就是工作区根目录）
function Get-CurrentProject {
    return Get-ScriptifyRoot
}

# 获取项目名称（从配置文件读取）
function Get-ProjectName {
    $scriptifyRoot = Get-ScriptifyRoot
    $configPath = Join-Path $scriptifyRoot ".scriptify/config.json"

    if (Test-Path $configPath) {
        $config = Get-Content $configPath | ConvertFrom-Json
        return $config.name
    } else {
        return Split-Path $scriptifyRoot -Leaf
    }
}

# 创建带编号的目录
function New-NumberedDirectory {
    param(
        [string]$BaseDir,
        [string]$Prefix
    )

    if (-not (Test-Path $BaseDir)) {
        New-Item -ItemType Directory -Path $BaseDir -Force | Out-Null
    }

    # 找到最高编号
    $highest = 0
    Get-ChildItem -Path $BaseDir -Directory | ForEach-Object {
        if ($_.Name -match '^(\d+)') {
            $number = [int]$matches[1]
            if ($number -gt $highest) {
                $highest = $number
            }
        }
    }

    # 返回下一个编号
    $next = $highest + 1
    return "{0:D3}" -f $next
}

# 输出 JSON（用于与 AI 助手通信）
function Output-Json {
    param([object]$Object)

    if ($Object -is [string]) {
        Write-Output $Object
    } else {
        $Object | ConvertTo-Json -Depth 10 -Compress
    }
}

# 确保文件存在
function Ensure-File {
    param(
        [string]$File,
        [string]$Template
    )

    if (-not (Test-Path $File)) {
        if (Test-Path $Template) {
            Copy-Item $Template $File
        } else {
            New-Item -ItemType File -Path $File -Force | Out-Null
        }
    }
}

# 准确的字数统计（支持剧本格式）
# 排除场景描述、人物名等格式标记，只统计对话和叙述内容
function Count-ScriptWords {
    param([string]$FilePath)

    if (-not (Test-Path $FilePath)) {
        return 0
    }

    $content = Get-Content $FilePath -Raw

    # 移除代码块
    $content = $content -replace '(?s)```.*?```', ''

    # 移除 Markdown 标记
    $content = $content -replace '^#+\s*', ''
    $content = $content -replace '\*\*', ''
    $content = $content -replace '__', ''
    $content = $content -replace '\*', ''
    $content = $content -replace '_', ''
    $content = $content -replace '\[', ''
    $content = $content -replace '\]', ''
    $content = $content -replace '\(http[^\)]*\)', ''
    $content = $content -replace '^>\s*', ''

    # 移除所有空白和标点
    $content = $content -replace '\s', ''
    $content = $content -replace '[^\p{L}\p{N}]', ''

    # 统计字符数
    return $content.Length
}

# 显示友好的字数信息
function Show-WordCountInfo {
    param(
        [string]$FilePath,
        [int]$MinWords = 0,
        [int]$MaxWords = 999999
    )

    $actualWords = Count-ScriptWords -FilePath $FilePath

    Write-Output "字数：$actualWords"

    if ($MinWords -gt 0) {
        if ($actualWords -lt $MinWords) {
            Write-Output "⚠️ 未达到最低字数要求（最小：$MinWords）"
        } elseif ($actualWords -gt $MaxWords) {
            Write-Output "⚠️ 超过最大字数限制（最大：$MaxWords）"
        } else {
            Write-Output "✅ 符合字数要求（$MinWords-$MaxWords）"
        }
    }
}

# 检查spec.json配置文件是否存在
function Test-SpecExists {
    $projectDir = Get-CurrentProject
    $configFile = Join-Path $projectDir "spec.json"

    if (-not (Test-Path $configFile)) {
        $error = @{
            status = "error"
            message = "项目配置文件不存在，请先运行 /spec 定义剧本规格"
        }
        Output-Json $error
        exit 1
    }

    return $configFile
}
