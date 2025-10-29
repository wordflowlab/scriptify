# Scene (分场)

# 加载通用函数
. "$PSScriptRoot\common.ps1"

# 获取项目路径
$projectDir = Get-CurrentProject
$projectName = Get-ProjectName

# 检查前置文件
$specFile = Test-SpecExists
$outlineFile = Join-Path $projectDir "outline.md"

if (-not (Test-Path $outlineFile)) {
    $error = @{
        status = "error"
        message = "请先运行 /outline 完成故事大纲"
    }
    Output-Json $error
    exit 1
}

$sceneFile = Join-Path $projectDir "scene.md"

# 读取已有内容
$specContent = Get-Content $specFile | ConvertFrom-Json
$outlineContent = Get-Content $outlineFile -Raw

# 检查是否已有分场大纲
if (Test-Path $sceneFile) {
    $existingScene = Get-Content $sceneFile -Raw
    $wordCount = Count-ScriptWords -FilePath $sceneFile

    $result = @{
        status = "success"
        action = "review"
        project_name = $projectName
        scene_file = $sceneFile
        spec = $specContent
        outline_content = $outlineContent
        existing_scene = $existingScene
        word_count = $wordCount
        message = "发现已有分场大纲，AI 可引导用户审查或修改"
    }

    Output-Json $result
} else {
    # 创建分场模板
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $template = @"
# 分场大纲

## 场次列表

### 第1集

**场1-1**: 
- 地点：
- 时间：日/夜
- 人物：
- 目的：
- 冲突：

**场1-2**:
- 地点：
- 时间：日/夜
- 人物：
- 目的：
- 冲突：

---
创建时间: $timestamp
"@

    Set-Content -Path $sceneFile -Value $template

    $result = @{
        status = "success"
        action = "create"
        project_name = $projectName
        scene_file = $sceneFile
        spec = $specContent
        outline_content = $outlineContent
        message = "已创建分场模板，AI 应引导用户填写"
    }

    Output-Json $result
}
