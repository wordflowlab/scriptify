# 故事大纲

# 加载通用函数
. "$PSScriptRoot\common.ps1"

# 获取项目路径
$projectDir = Get-CurrentProject
$projectName = Get-ProjectName

# 检查前置文件
$specFile = Test-SpecExists
$ideaFile = Join-Path $projectDir "idea.md"

if (-not (Test-Path $ideaFile)) {
    $error = @{
        status = "error"
        message = "请先运行 /idea 完成故事构思"
    }
    Output-Json $error
    exit 1
}

$outlineFile = Join-Path $projectDir "outline.md"
$progressFile = Join-Path $projectDir ".scriptify" "progress.json"

# 读取已有内容
$specContent = Get-Content $specFile | ConvertFrom-Json
$ideaContent = Get-Content $ideaFile -Raw

# 检查进度文件
$progressData = @{}
if (Test-Path $progressFile) {
    $progress = Get-Content $progressFile | ConvertFrom-Json
    if ($progress.PSObject.Properties.Name -contains "outline") {
        $progressData = $progress.outline
    }
}

# 检查是否已有大纲
if (Test-Path $outlineFile) {
    $existingOutline = Get-Content $outlineFile -Raw
    $wordCount = Count-ScriptWords -FilePath $outlineFile

    $result = @{
        status = "success"
        action = "review"
        project_name = $projectName
        outline_file = $outlineFile
        spec = $specContent
        idea_content = $ideaContent
        existing_outline = $existingOutline
        word_count = $wordCount
        progress = $progressData
        message = "发现已有大纲，AI 可引导用户审查或修改"
    }

    Output-Json $result
} else {
    # 创建大纲模板
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $template = @"
# 故事大纲

## 三幕结构

### 第一幕：建置 (Setup)
**目标**: 介绍世界观、主角、日常生活

- 开场（Hook）：
- 主角的日常世界：
- 激励事件（Inciting Incident）：
- 第一幕转折点：

### 第二幕：对抗 (Confrontation)
**目标**: 主角面对困难、成长、挣扎

- 主角的计划：
- B故事线（副线）：
- 中点（Midpoint）转折：
- 低谷时刻（All is Lost）：
- 第二幕转折点：

### 第三幕：解决 (Resolution)
**目标**: 高潮对决、解决问题、完成弧线

- 主角的觉悟：
- 高潮对决：
- 结局：
- 尾声（如有）：

## 核心节拍（Beat Sheet）

1. 开场画面：
2. 主题陈述：
3. 铺陈：
4. 推动剂：
5. 争论：
6. 进入第二幕：
7. B故事线：
8. 娱乐时刻：
9. 中点：
10. 坏人逼近：
11. 一无所有：
12. 灵魂暗夜：
13. 进入第三幕：
14. 决战：
15. 结局：

---
创建时间: $timestamp
"@

    Set-Content -Path $outlineFile -Value $template

    $result = @{
        status = "success"
        action = "create"
        project_name = $projectName
        outline_file = $outlineFile
        spec = $specContent
        idea_content = $ideaContent
        progress = $progressData
        message = "已创建大纲模板，AI 可根据模式引导用户填写"
    }

    Output-Json $result
}
