@{
    RootModule = 'FastGo.psm1'
    ModuleVersion = '1.2.0'
    GUID = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
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
            LicenseUri = ''
            ProjectUri = ''
            ReleaseNotes = 'v1.2.0 - 优化函数命名'
        }
    }
}