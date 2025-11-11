@{
    RootModule = 'FuncSz.psm1'
    ModuleVersion = '1.0.2'
    GUID = '7d682d26-92ea-461b-bcf0-c4b15be3a72b'
    Author = 'Sidney Zhang<zly@lyzhang.me>'
    CompanyName = 'Sidney Zhang'
    Copyright = '(c) 2024 Sidney Zhang. All rights reserved.'
    Description = 'PowerShell 实用函数模块集合，包含虚拟环境管理、API密钥生成、目录跳转和符号链接创建等功能。'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
        'Enter-Venv',
        'Exit-Venv',
        'New-ApiKey',
        'Add-JumpFunction',
        'Set-Symlink',
        'Start-Shortcut'
    )
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('Python', 'VirtualEnvironment', 'API', 'Symlink', 'Jump', 'Utility')
            LicenseUri = 'https://github.com/SidneyLYZhang/favoConfigs/blob/main/LICENSE'
            ProjectUri = 'https://github.com/SidneyLYZhang/favoConfigs/tree/main/shell/favo.powershell/Modules/FuncSz'
            ReleaseNotes = 'v1.0.2 :
            - Enter-Venv: 自动查找并激活Python虚拟环境
            - Exit-Venv: 退出当前虚拟环境
            - New-ApiKey: 生成随机API密钥
            - Add-JumpFunction: 创建目录跳转函数
            - Set-Symlink: 创建符号链接工具
            - Start-Shortcut: 打开快捷方式 (.lnk)'
        }
    }
}