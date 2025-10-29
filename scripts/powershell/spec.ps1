# 定义/更新剧本规格

# 加载通用函数
. "$PSScriptRoot\common.ps1"

# 获取项目路径
$projectDir = Get-CurrentProject
$projectName = Get-ProjectName

$specFile = Join-Path $projectDir "spec.json"
$configFile = Join-Path $projectDir ".scriptify" "config.json"

# 读取 config.json 中的 defaultType (如果存在)
$defaultType = ""
if (Test-Path $configFile) {
    $config = Get-Content $configFile | ConvertFrom-Json
    if ($config.PSObject.Properties.Name -contains "defaultType") {
        $defaultType = $config.defaultType
    }
}

# 如果已有配置，读取现有配置
if (Test-Path $specFile) {
    $existingConfig = Get-Content $specFile | ConvertFrom-Json

    $result = @{
        status = "success"
        action = "update"
        project_name = $projectName
        project_path = $projectDir.Path
        spec_file = $specFile
        existing_config = $existingConfig
        message = "找到现有配置，AI 可引导用户更新"
    }

    Output-Json $result
} else {
    # 创建初始配置模板
    $timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

    $initialConfig = @{
        project_name = $projectName
        type = $defaultType
        duration = ""
        episodes = 0
        genre = ""
        audience = @{
            age = ""
            gender = ""
        }
        target_platform = @()
        tone = ""
        created_at = $timestamp
        updated_at = $timestamp
    }

    $initialConfig | ConvertTo-Json -Depth 10 | Set-Content $specFile

    $result = @{
        status = "success"
        action = "create"
        project_name = $projectName
        project_path = $projectDir.Path
        spec_file = $specFile
        default_type = $defaultType
        message = "已创建配置模板，AI 应引导用户填写以下信息"
        required_fields = @(
            "type (类型): 短剧/短视频/长剧/电影",
            "duration (时长): 如 '10分钟×10集' 或 '90分钟'",
            "genre (题材): 悬疑/言情/职场/古装等",
            "audience (受众): 年龄段和性别",
            "target_platform (目标平台): 抖音/快手/B站/长视频平台等"
        )
    }

    Output-Json $result
}
