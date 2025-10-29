# 人物设定

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

$charactersFile = Join-Path $projectDir "characters.md"

# 读取已有内容
$specContent = Get-Content $specFile | ConvertFrom-Json
$ideaContent = Get-Content $ideaFile -Raw

# 检查是否已有人物设定
if (Test-Path $charactersFile) {
    $existingCharacters = Get-Content $charactersFile -Raw
    $wordCount = Count-ScriptWords -FilePath $charactersFile

    $result = @{
        status = "success"
        action = "review"
        project_name = $projectName
        characters_file = $charactersFile
        spec = $specContent
        idea_content = $ideaContent
        existing_characters = $existingCharacters
        word_count = $wordCount
        message = "发现已有人物设定，AI 可引导用户审查或补充"
    }

    Output-Json $result
} else {
    # 创建人物设定模板
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $template = @"
# 人物设定

## 主要角色

### 主角
**姓名**：
**年龄**：
**职业**：
**性格**：
**外貌**：
**目标**：
**弱点**：
**成长弧线**：

### 配角1
**姓名**：
**年龄**：
**职业**：
**性格**：
**与主角关系**：
**在故事中的作用**：

### 配角2
**姓名**：
**年龄**：
**职业**：
**性格**：
**与主角关系**：
**在故事中的作用**：

## 次要角色
（根据需要添加）

---
创建时间: $timestamp
"@

    Set-Content -Path $charactersFile -Value $template

    $result = @{
        status = "success"
        action = "create"
        project_name = $projectName
        characters_file = $charactersFile
        spec = $specContent
        idea_content = $ideaContent
        message = "已创建人物设定模板，AI 应引导用户填写"
    }

    Output-Json $result
}
