<#
.SYNOPSIS
    批量设置/取消常用开发工具的 HTTP(S) 代理。

.DESCRIPTION
    内置 git、scoop、npm、yarn；
    同时支持 HTTP 和 HTTPS 代理设置；
    同时允许自定义任意新工具。
    默认代理 127.0.0.1:7890，可通过 -Proxy 修改。

.PARAMETER Tool
    要配置的工具名，支持数组；内置工具直接写名字即可，
    自定义工具需同时给出 -SetCmd 与 -UnsetCmd。

.PARAMETER Proxy
    代理地址，缺省为 http://127.0.0.1:7890
    支持格式：http://host:port 或 https://host:port

.PARAMETER HttpsProxy
    HTTPS 代理地址，如果不指定则使用与 HTTP 代理相同的地址

.PARAMETER Unset
    如果给出该开关，则取消代理；否则设置代理。

.PARAMETER SetCmd
    仅对"自定义工具"有效：设置代理时要执行的命令模板。
    支持占位符：{proxy}、{http_proxy}、{https_proxy}
    例如："mycli config proxy.url {proxy}"

.PARAMETER UnsetCmd
    仅对"自定义工具"有效：取消代理时要执行的命令。

.PARAMETER ListSupported
    列出所有支持的内置工具

.EXAMPLE
    Set-ToolProxy git npm scoop cargo    # 一键设置所有工具代理

.EXAMPLE
    Set-ToolProxy scoop -u               # 取消 scoop 代理

.EXAMPLE
    Set-ToolProxy git -Proxy http://proxy.lan:8080

.EXAMPLE
    Set-ToolProxy cargo -HttpsProxy https://proxy.lan:8443

.EXAMPLE
    Set-ToolProxy mytool -SetCmd "mytool config http.proxy {http_proxy} && mytool config https.proxy {https_proxy}" `
                         -UnsetCmd "mytool config --unset http.proxy && mytool config --unset https.proxy"
#>
function Set-ToolProxy {
    [CmdletBinding(DefaultParameterSetName = 'SetProxy')]
    param(
        [Parameter(Mandatory, Position = 0, ParameterSetName = 'SetProxy')]
        [string[]]$Tool,

        [Parameter(ParameterSetName = 'ListSupported')]
        [switch]$ListSupported,

        [string]$Proxy = 'http://127.0.0.1:7890',

        [string]$HttpsProxy,

        [Alias('u')]
        [switch]$Unset,

        [string]$SetCmd,   # 仅自定义工具时有效
        [string]$UnsetCmd  # 仅自定义工具时有效
    )

    # 如果没有指定 HTTPS 代理，则使用与 HTTP 代理相同的地址
    if ([string]::IsNullOrEmpty($HttpsProxy)) {
        $HttpsProxy = $Proxy
    }

    # 内置工具的配置表 - 支持 HTTP 和 HTTPS 代理
    $builtin = @{
        git = @{
            Set = @{
                http  = "git config --global http.proxy $Proxy"
                https = "git config --global https.proxy $HttpsProxy"
            }
            Unset = @{
                http  = 'git config --global --unset http.proxy'
                https = 'git config --global --unset https.proxy'
            }
            Description = 'Git 版本控制系统'
        }
        scoop = @{
            Set = @{
                default = "scoop config proxy $Proxy"
            }
            Unset = @{
                default = 'scoop config rm proxy'
            }
            Description = 'Windows 包管理器'
        }
        npm = @{
            Set = @{
                http  = "npm config set proxy $Proxy"
                https = "npm config set https-proxy $HttpsProxy"
            }
            Unset = @{
                http  = 'npm config delete proxy'
                https = 'npm config delete https-proxy'
            }
            Description = 'Node.js 包管理器'
        }
        yarn = @{
            Set = @{
                http  = "yarn config set proxy $Proxy"
                https = "yarn config set https-proxy $HttpsProxy"
            }
            Unset = @{
                http  = 'yarn config delete proxy'
                https = 'yarn config delete https-proxy'
            }
            Description = 'Yarn 包管理器'
        }
    }

    # 如果请求列出支持的工具
    if ($ListSupported) {
        Write-Host "`n支持的内置工具：" -ForegroundColor Cyan
        Write-Host ("=" * 50)
        foreach ($toolName in ($builtin.Keys | Sort-Object)) {
            $desc = $builtin[$toolName].Description
            $note = if ($builtin[$toolName].Note) { " (" + $builtin[$toolName].Note + ")" } else { "" }
            Write-Host "  $toolName" -ForegroundColor Green -NoNewline
            Write-Host " - $desc$note"
        }
        Write-Host ("=" * 50)
        return
    }

    foreach ($t in $Tool) {
        Write-Host "`n==> 处理 $t" -ForegroundColor Cyan
        try {
            # 1. 内置工具分支
            if ($builtin.ContainsKey($t)) {
                $toolConfig = $builtin[$t]
                
                if ($Unset) {
                    # 取消代理设置
                    if ($toolConfig.Unset.default) {
                        Invoke-Expression $toolConfig.Unset.default
                    }
                    elseif ($toolConfig.Unset.http) {
                        Invoke-Expression $toolConfig.Unset.http
                        if ($toolConfig.Unset.https) {
                            Invoke-Expression $toolConfig.Unset.https
                        }
                    }
                    elseif ($toolConfig.Unset.env) {
                        # 设置环境变量
                        foreach ($envVar in $toolConfig.Unset.env.Keys) {
                            [Environment]::SetEnvironmentVariable($envVar, $toolConfig.Unset.env[$envVar], 'User')
                        }
                    }
                }
                else {
                    # 设置代理
                    if ($toolConfig.Set.default) {
                        if ($toolConfig.Set.default -is [string]) {
                            Invoke-Expression $toolConfig.Set.default
                        }
                    }
                    elseif ($toolConfig.Set.http) {
                        Invoke-Expression $toolConfig.Set.http
                        if ($toolConfig.Set.https) {
                            Invoke-Expression $toolConfig.Set.https
                        }
                    }
                    elseif ($toolConfig.Set.env) {
                        # 设置环境变量
                        foreach ($envVar in $toolConfig.Set.env.Keys) {
                            [Environment]::SetEnvironmentVariable($envVar, $toolConfig.Set.env[$envVar], 'User')
                        }
                    }
                }
                
                if ($toolConfig.Note) {
                    Write-Host "提示: $($toolConfig.Note)" -ForegroundColor DarkYellow
                }
            }
            # 2. 自定义工具分支
            elseif ($PSBoundParameters.ContainsKey('SetCmd') -and
                    $PSBoundParameters.ContainsKey('UnsetCmd')) {
                $template = if ($Unset) { $UnsetCmd } else { $SetCmd }
                $cmd = $template -replace '\{proxy}', $Proxy
                $cmd = $cmd -replace '\{http_proxy}', $Proxy
                $cmd = $cmd -replace '\{https_proxy}', $HttpsProxy
                Invoke-Expression $cmd
            }
            elseif ($Unset -and $PSBoundParameters.ContainsKey('UnsetCmd')) {
                # 取消代理时只需要 UnsetCmd
                $cmd = $UnsetCmd -replace '\{proxy}', $Proxy
                $cmd = $cmd -replace '\{http_proxy}', $Proxy
                $cmd = $cmd -replace '\{https_proxy}', $HttpsProxy
                Invoke-Expression $cmd
            }
            else {
                Write-Warning "未知工具 '$t'，请提供 -SetCmd 与 -UnsetCmd 参数，或使用 -ListSupported 查看支持的工具"
                continue
            }
            Write-Host "[OK] $t 设置完成!" -ForegroundColor Green
        }
        catch {
            Write-Error "[FAIL] $t : $_"
        }
    }
}

<#
.SYNOPSIS
    显示当前已配置的代理设置。

.DESCRIPTION
    检查常用开发工具的当前代理配置状态。

.PARAMETER Tool
    要检查的工具名，如果不指定则检查所有支持的工具。

.EXAMPLE
    Get-ToolProxy

.EXAMPLE
    Get-ToolProxy git npm
#>
function Get-ToolProxy {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string[]]$Tool
    )

    $supportedTools = @('git', 'scoop', 'npm', 'yarn')
    
    if (-not $Tool) {
        $Tool = $supportedTools
    }

    Write-Host "`n当前代理配置状态：" -ForegroundColor Cyan
    Write-Host ("=" * 60)

    foreach ($t in $Tool) {
        if ($t -notin $supportedTools) {
            Write-Warning "不支持的工具: $t"
            continue
        }

        Write-Host "`n[$t]" -ForegroundColor Green
        
        try {
            switch ($t) {
                'git' {
                    $httpProxy = git config --global http.proxy 2>$null
                    $httpsProxy = git config --global https.proxy 2>$null
                    if ($httpProxy) { Write-Host "  HTTP 代理: $httpProxy" }
                    if ($httpsProxy) { Write-Host "  HTTPS 代理: $httpsProxy" }
                    if (-not $httpProxy -and -not $httpsProxy) { Write-Host "  未设置代理" -ForegroundColor Gray }
                }
                'scoop' {
                    $proxy = scoop config proxy 2>$null
                    if ($proxy) { Write-Host "  代理: $proxy" } else { Write-Host "  未设置代理" -ForegroundColor Gray }
                }
                'npm' {
                    $httpProxy = npm config get proxy 2>$null
                    $httpsProxy = npm config get https-proxy 2>$null
                    if ($httpProxy -and $httpProxy -ne 'null') { Write-Host "  HTTP 代理: $httpProxy" }
                    if ($httpsProxy -and $httpsProxy -ne 'null') { Write-Host "  HTTPS 代理: $httpsProxy" }
                    if ((-not $httpProxy -or $httpProxy -eq 'null') -and (-not $httpsProxy -or $httpsProxy -eq 'null')) { 
                        Write-Host "  未设置代理" -ForegroundColor Gray 
                    }
                }
                'yarn' {
                    $httpProxy = yarn config get proxy 2>$null
                    $httpsProxy = yarn config get https-proxy 2>$null
                    if ($httpProxy -and $httpProxy -ne 'null') { Write-Host "  HTTP 代理: $httpProxy" }
                    if ($httpsProxy -and $httpsProxy -ne 'null') { Write-Host "  HTTPS 代理: $httpsProxy" }
                    if ((-not $httpProxy -or $httpProxy -eq 'null') -and (-not $httpsProxy -or $httpsProxy -eq 'null')) { 
                        Write-Host "  未设置代理" -ForegroundColor Gray 
                    }
                }
            }
        }
        catch {
            Write-Error "检查 $t 时出错: $_"
        }
    }
    Write-Host ("=" * 60)
}

function Get-EnvProxy {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string[]]$Key,
        
        [Parameter(ParameterSetName = 'SupportedTools')]
        [switch]$SupportedTools
    )

    # 环境变量代理支持的工具列表
    $envProxyTools = @{
        stack = @{
            Description = 'Haskell Stack 构建工具'
            EnvVars = @('HTTP_PROXY', 'HTTPS_PROXY')
            Note = '自动检测 HTTP_PROXY 和 HTTPS_PROXY 环境变量'
        }
        cabal = @{
            Description = 'Haskell Cabal 包管理器'
            EnvVars = @('HTTP_PROXY', 'HTTPS_PROXY')
            Note = '自动检测 HTTP_PROXY 和 HTTPS_PROXY 环境变量'
        }
        cargo = @{
            Description = 'Rust Cargo 包管理器'
            EnvVars = @('HTTP_PROXY', 'HTTPS_PROXY')
            Note = '自动检测 HTTP_PROXY 和 HTTPS_PROXY 环境变量'
        }
        pip = @{
            Description = 'Python pip 包管理器'
            EnvVars = @('HTTP_PROXY', 'HTTPS_PROXY', 'http_proxy', 'https_proxy')
            Note = '支持大小写不敏感的环境变量检测'
        }
        alen = @{
            Description = 'Alen 包管理器'
            EnvVars = @('HTTP_PROXY', 'HTTPS_PROXY')
            Note = '自动检测 HTTP_PROXY 和 HTTPS_PROXY 环境变量'
        }
        curl = @{
            Description = 'cURL 命令行工具'
            EnvVars = @('HTTP_PROXY', 'HTTPS_PROXY', 'http_proxy', 'https_proxy')
            Note = '支持大小写不敏感的环境变量检测'
        }
        wget = @{
            Description = 'Wget 命令行下载工具'
            EnvVars = @('http_proxy', 'https_proxy', 'HTTP_PROXY', 'HTTPS_PROXY')
            Note = '支持大小写不敏感的环境变量检测'
        }
        docker = @{
            Description = 'Docker 容器平台'
            EnvVars = @('HTTP_PROXY', 'HTTPS_PROXY', 'NO_PROXY')
            Note = '同时支持 NO_PROXY 环境变量'
        }
        go = @{
            Description = 'Go 模块代理'
            EnvVars = @('HTTP_PROXY', 'HTTPS_PROXY', 'GOPROXY')
            Note = '支持 GOPROXY 和 HTTP_PROXY/HTTPS_PROXY'
        }
        rustup = @{
            Description = 'Rust 工具链管理器'
            EnvVars = @('HTTP_PROXY', 'HTTPS_PROXY')
            Note = '自动检测 HTTP_PROXY 和 HTTPS_PROXY 环境变量'
        }
    }

    # 如果请求显示支持的工具列表
    if ($SupportedTools) {
        Write-Host "`n支持环境变量代理的工具：" -ForegroundColor Cyan
        Write-Host ("=" * 60)
        foreach ($toolName in ($envProxyTools.Keys | Sort-Object)) {
            $tool = $envProxyTools[$toolName]
            Write-Host "  $toolName" -ForegroundColor Green -NoNewline
            Write-Host " - $($tool.Description)"
            Write-Host "    环境变量: $($tool.EnvVars -join ', ')" -ForegroundColor Gray
            if ($tool.Note) {
                Write-Host "    说明: $($tool.Note)" -ForegroundColor DarkYellow
            }
        }
        Write-Host ("=" * 60)
        return
    }

    # 检查环境变量代理设置
    Write-Host "`n当前环境变量代理设置：" -ForegroundColor Cyan
    Write-Host ("=" * 50)

    # 检查主要的环境变量
    $proxyEnvVars = @('HTTP_PROXY', 'HTTPS_PROXY', 'http_proxy', 'https_proxy', 'NO_PROXY', 'no_proxy')
    $foundAny = $false

    foreach ($envVar in $proxyEnvVars) {
        $value = [Environment]::GetEnvironmentVariable($envVar)
        if ($value) {
            Write-Host "  $envVar" -ForegroundColor Green -NoNewline
            Write-Host " = $value"
            $foundAny = $true
        }
    }

    if (-not $foundAny) {
        Write-Host "  未设置任何代理环境变量" -ForegroundColor Gray
    }

    # 检查特定键的环境变量（如果指定了）
    if ($Key) {
        Write-Host "`n指定的环境变量检查：" -ForegroundColor Yellow
        foreach ($k in $Key) {
            $value = [Environment]::GetEnvironmentVariable($k)
            if ($value) {
                Write-Host "  $k = $value" -ForegroundColor Green
            } else {
                Write-Host "  $k 未设置" -ForegroundColor Gray
            }
        }
    }

    Write-Host ("=" * 50)

    # 显示使用提示
    Write-Host "`n使用提示:" -ForegroundColor DarkCyan
    Write-Host "  - 使用 -SupportedTools 参数查看支持环境变量代理的工具列表"
    Write-Host "  - 大多数工具会自动检测 HTTP_PROXY 和 HTTPS_PROXY 环境变量"
    Write-Host "  - 某些工具也支持小写版本 (http_proxy, https_proxy)"
}

Export-ModuleMember -Function Set-ToolProxy, Get-ToolProxy, Get-EnvProxy