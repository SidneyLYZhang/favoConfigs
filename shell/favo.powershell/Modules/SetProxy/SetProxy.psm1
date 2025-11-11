function Set-ToolProxy {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [string[]]$Tool,
        
        [Parameter(Position = 1)]
        [string]$Proxy = "http://127.0.0.1:7890",
        
        [Parameter(Position = 2)]
        [string]$HttpsProxy,
        
        [Parameter()]
        [switch]$ListSupported,
        
        [Parameter()]
        [switch]$Unset,
        
        [Parameter(ParameterSetName = 'Custom')]
        [string]$SetCmd,
        
        [Parameter(ParameterSetName = 'Custom')]
        [string]$UnsetCmd
    )

    # 内置工具配置表
    $builtin = @{
        git = @{
            Set = @{
                http  = "git config --global http.proxy `$Proxy"
                https = "git config --global https.proxy `$HttpsProxy"
            }
            Unset = @{
                http  = "git config --global --unset http.proxy"
                https = "git config --global --unset https.proxy"
            }
            Note = "Git 会分别设置 http 和 https 代理"
        }
        scoop = @{
            Set = @{
                default = "scoop config proxy `$Proxy"
            }
            Unset = @{
                default = "scoop config rm proxy"
            }
            Note = "Scoop 使用单一代理设置"
        }
        npm = @{
            Set = @{
                http  = "npm config set proxy `$Proxy"
                https = "npm config set https-proxy `$HttpsProxy"
            }
            Unset = @{
                http  = "npm config rm proxy"
                https = "npm config rm https-proxy"
            }
            Note = "npm 会分别设置 http 和 https 代理"
        }
        yarn = @{
            Set = @{
                http  = "yarn config set proxy `$Proxy"
                https = "yarn config set https-proxy `$HttpsProxy"
            }
            Unset = @{
                http  = "yarn config rm proxy"
                https = "yarn config rm https-proxy"
            }
            Note = "Yarn 会分别设置 http 和 https 代理"
        }
    }

    # 如果未指定 HttpsProxy，使用与 Proxy 相同的值
    if ([string]::IsNullOrEmpty($HttpsProxy)) {
        $HttpsProxy = $Proxy
    }

    # 处理 -ListSupported 参数
    if ($ListSupported) {
        Write-Host "`n支持的工具列表：" -ForegroundColor Cyan
        Write-Host ("=" * 50)
        foreach ($toolName in ($builtin.Keys | Sort-Object)) {
            $tool = $builtin[$toolName]
            $desc = $tool.Note ?? "支持代理设置"
            $note = if ($tool.Set.default) { " (命令行)" } elseif ($tool.Set.env) { " (环境变量)" } else { "" }
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
                            # 针对 scoop 的特殊处理：移除协议前缀
                            if ($t -eq 'scoop') {
                                $proxyValue = $Proxy -replace '^https?://', ''
                                $command = "scoop config proxy $proxyValue"
                                Invoke-Expression $command
                            }
                            else {
                                Invoke-Expression $toolConfig.Set.default
                            }
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
                            $value = $toolConfig.Set.env[$envVar] -f $Proxy, $HttpsProxy
                            [Environment]::SetEnvironmentVariable($envVar, $value, 'User')
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
        elan = @{
            Description = 'Lean4 elan 包管理器'
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