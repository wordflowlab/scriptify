# Visualize

# 加载通用函数
. "$PSScriptRoot\common.ps1"

# 获取项目路径
$projectDir = Get-CurrentProject
$projectName = Get-ProjectName

$result = @{
    status = "success"
    project_name = $projectName
    project_path = $projectDir.Path
    message = "Visualize - PowerShell 脚本已创建"
}

Output-Json $result
