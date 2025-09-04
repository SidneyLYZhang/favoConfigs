@{
    RootModule = 'FastGo.psm1'
    ModuleVersion = '1.2.0'
    GUID = '425cee35-8f7e-498a-b5a5-0bf55a9c1f38'
    Author = 'Sidney Zhang'
    CompanyName = 'Sidney Zhang'
    Copyright = '(c) 2025 Sidney Zhang. All rights reserved.'
    Description = '快速目录导航工具，支持自定义目录映射和快捷方式'
    PowerShellVersion = '5.1'
    FunctionsToExport = @('Invoke-Go', 'Open-Folder', 'Get-GoMap', 'Set-GoMap')
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('Navigation', 'Directory', 'Productivity', 'Utility')
            LicenseUri = 'https://github.com/SidneyLYZhang/favoConfigs/blob/main/LICENSE'
            ProjectUri = 'https://github.com/SidneyLYZhang/favoConfigs/tree/main/shell/favo.powershell/Modules/FastGo'
            ReleaseNotes = 'v1.2.0 - 优化函数命名'
        }
    }
}