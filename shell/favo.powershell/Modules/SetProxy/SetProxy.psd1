@{
    RootModule = 'SetProxy.psm1'
    ModuleVersion = '2.0.0'
    GUID = 'cb5a6a42-a2c1-4797-b6fa-44e40157c5cd'
    Author = 'Sidney Zhang<zly@lyzhang.me>'
    CompanyName = 'Sidney Zhang'
    Copyright = '(c) 2025 Sidney Zhang. All rights reserved.'
    Description = '批量设置和管理开发工具的 HTTP/HTTPS 代理配置'
    
    # 支持的最低 PowerShell 版本
    PowerShellVersion = '5.1'
    
    # 导出的函数
    FunctionsToExport = @('Set-ToolProxy', 'Get-ToolProxy', 'Get-EnvProxy')
    
    # 导出的别名
    AliasesToExport = @()
    
    # 私有数据
    PrivateData = @{
        PSData = @{
            # 标签
            Tags = @('Proxy', 'HTTP', 'HTTPS', 'Git', 'NPM', 'Yarn', 'Scoop', 'Development')
            
            # 项目 URI
            ProjectUri = ''
            
            # 发布说明
            ReleaseNotes = '
            2.0.0 版本更新：
            - 支持同时设置 HTTP 和 HTTPS 代理
            - 增强自定义工具配置能力
            - 新增 Get-ToolProxy 函数用于查看当前代理状态
            '
        }
    }
}