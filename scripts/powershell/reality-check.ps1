# Reality Check - 市场现实检查

# 加载通用函数
. "$PSScriptRoot\common.ps1"

# 获取项目路径
try {
    $projectDir = Get-ScriptifyRoot
} catch {
    Output-Json @{
        status = "error"
        error_code = "NOT_IN_PROJECT"
        message = "未找到 .scriptify 项目目录。请先运行 scriptify new 创建项目。"
    }
    exit 1
}

$projectName = Get-ProjectName
$specFile = Join-Path $projectDir "spec.json"
$ideaFile = Join-Path $projectDir "idea.md"

# 检查 spec.json 是否存在
if (-not (Test-Path $specFile)) {
    Output-Json @{
        status = "error"
        error_code = "SPEC_NOT_FOUND"
        message = "spec.json 未找到。请先运行 /spec 命令设置剧本规格。"
    }
    exit 1
}

# 检查 idea.md 是否存在
if (-not (Test-Path $ideaFile)) {
    Output-Json @{
        status = "error"
        error_code = "IDEA_NOT_FOUND"
        message = "请先运行 /idea 命令完成创意构思。市场检查需要基于你的故事创意进行。"
    }
    exit 1
}

# 读取 spec.json
$spec = Get-Content $specFile | ConvertFrom-Json

# 读取 idea.md 内容
$ideaContent = Get-Content $ideaFile -Raw

# 提取故事核心(一句话)
$ideaSummary = ""
if ($ideaContent -match "## 故事核心[^\n]*\n([^\n]+)") {
    $ideaSummary = $matches[1].Trim()
}

# 提取主角信息
$protagonistIdentity = ""
$protagonistTrait = ""
if ($ideaContent -match "## 主角[\s\S]*?身份:\s*([^\n]+)") {
    $protagonistIdentity = $matches[1].Trim()
}
if ($ideaContent -match "## 主角[\s\S]*?性格:\s*([^\n]+)") {
    $protagonistTrait = $matches[1].Trim()
}

# 提取目标
$goal = ""
if ($ideaContent -match "## 目标[\s\S]*?目标:\s*([^\n]+)") {
    $goal = $matches[1].Trim()
}

# 提取障碍
$externalObstacle = ""
$internalWeakness = ""
if ($ideaContent -match "## 障碍[\s\S]*?外部障碍:\s*([^\n]+)") {
    $externalObstacle = $matches[1].Trim()
}
if ($ideaContent -match "## 障碍[\s\S]*?内部弱点:\s*([^\n]+)") {
    $internalWeakness = $matches[1].Trim()
}

# 获取平台信息
$platform = ""
if ($spec.PSObject.Properties.Name -contains "target_platform") {
    $platform = $spec.target_platform -join ", "
}

# 输出结果
$result = @{
    status = "success"
    project_name = $projectName
    project_path = $projectDir
    spec = @{
        type = $spec.type
        genre = $spec.genre
        platform = $platform
    }
    idea_summary = $ideaSummary
    protagonist = @{
        identity = $protagonistIdentity
        trait = $protagonistTrait
    }
    goal = $goal
    obstacle = @{
        external = $externalObstacle
        internal = $internalWeakness
    }
    idea_file = $ideaFile
    idea_content = $ideaContent
}

Output-Json $result
