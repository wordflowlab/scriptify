# 故事构思

# 加载通用函数
. "$PSScriptRoot\common.ps1"

# 获取项目路径
$projectDir = Get-CurrentProject
$projectName = Get-ProjectName

# 检查配置文件
$specFile = Test-SpecExists
$ideaFile = Join-Path $projectDir "idea.md"

# 读取剧本规格
$specContent = Get-Content $specFile | ConvertFrom-Json

# 检查是否已有创意文件
if (Test-Path $ideaFile) {
    $existingIdea = Get-Content $ideaFile -Raw
    $wordCount = Count-ScriptWords -FilePath $ideaFile

    $result = @{
        status = "success"
        action = "review"
        project_name = $projectName
        idea_file = $ideaFile
        spec = $specContent
        existing_idea = $existingIdea
        word_count = $wordCount
        message = "发现已有创意，AI 可引导用户审查或修改"
    }

    Output-Json $result
} else {
    # 创建创意模板
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $template = @"
# 故事创意

## 故事核心

### 主角
- 姓名：
- 职业/身份：
- 年龄/性格：
- 核心特质：

### 目标
主角想要达成什么？

### 障碍
什么阻止主角达成目标？

### 人物弧线
主角如何成长/转变？（从A点到B点）

## 故事钩子
用一句话概括你的故事（30字以内）：

## 核心冲突

## 独特卖点
这个故事与众不同的地方：

---
创建时间: $timestamp
"@

    Set-Content -Path $ideaFile -Value $template

    $result = @{
        status = "success"
        action = "create"
        project_name = $projectName
        idea_file = $ideaFile
        spec = $specContent
        message = "已创建创意模板，AI 应引导用户思考并填写"
        guidance = "通过提问引导用户思考，而不是替用户想创意"
    }

    Output-Json $result
}
