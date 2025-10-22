#
# SetTempEnv PowerShell Module Manifest
#

@{
    # 根模块
    RootModule = 'SetTempEnv.psm1'
    
    # 模块版本号
    ModuleVersion = '2.0.0'
    
    # 支持的 PSEditions
    CompatiblePSEditions = @('Core', 'Desktop')
    
    # 模块ID
    GUID = 'aa0f2fe4-ee24-43ec-a410-35872d36997a'
    
    # 作者信息
    Author = 'Sidney Zhang'
    CompanyName = 'Sidney Zhang'
    
    # 版权声明
    Copyright = '(c) 2024 Sidney Zhang. All rights reserved.'
    
    # 模块描述
    Description = 'PowerShell模块，用于临时管理环境变量（仅当前会话有效）。支持备份、恢复、类型检测等高级功能。'
    
    # 最低 PowerShell 版本要求
    PowerShellVersion = '5.1'
    
    # 最低 .NET Framework 版本要求
    DotNetFrameworkVersion = '4.7.2'
    
    # 要导出的函数
    FunctionsToExport = @(
        'Set-TempEnv',
        'Get-TempEnv', 
        'Remove-TempEnv',
        'Clear-TempEnv',
        'Backup-TempEnv',
        'Restore-TempEnv',
        'Get-TempEnvType',
        'Get-TempEnvSystemVars'
    )
    
    # 要导出的cmdlet
    CmdletsToExport = @()
    
    # 要导出的变量
    VariablesToExport = @()
    
    # 要导出的别名
    AliasesToExport = @(
        'ste',  # Set-TempEnv
        'gte',  # Get-TempEnv
        'rte',  # Remove-TempEnv
        'cte',  # Clear-TempEnv
        'bte',  # Backup-TempEnv
        'rste'  # Restore-TempEnv
    )
    
    # 私有数据
    PrivateData = @{
        PSData = @{
            # 适用于此模块的标记
            Tags = @('Environment', 'Variables', 'Temporary', 'Session', 'Config', 'Backup', 'Restore', 'Management')
            
            # 许可证URI
            LicenseUri = 'https://github.com/sidneylyzhang/favoConfigs/blob/main/LICENSE'
            
            # 项目主页URI
            ProjectUri = 'https://github.com/favo/favoConfigs/tree/main/shell/favo.powershell/Modules/SetTempEnv'
            
            # 发布说明
            ReleaseNotes = @'
2.0.0 - 重大更新
- 修复 Set-TempEnv 函数中的重复验证逻辑
- 优化 Get-TempEnv 函数的类型检测逻辑，添加 -Detailed 参数
- 改进 Clear-TempEnv 函数的系统变量排除逻辑，添加 -ExcludePowerShell 参数
- 添加 Backup-TempEnv 和 Restore-TempEnv 函数用于备份和恢复环境变量
- 添加 Get-TempEnvType 函数用于智能检测环境变量类型
- 添加 Get-TempEnvSystemVars 函数获取系统变量列表
- 改进错误处理和用户界面
- 支持 WhatIf 和 Force 参数
- 添加更多实用别名
- 优化性能和内存使用
'@
        }
    }
    
    # 帮助信息URI
    HelpInfoURI = 'https://github.com/sidneylyzhang/favoConfigs/wiki/SetTempEnv'
}