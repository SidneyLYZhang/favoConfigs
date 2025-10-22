<#
.SYNOPSIS
    批量设置/取消常用开发工具的 HTTP(S) 代理。

.DESCRIPTION
    内置 git、scoop、npm、yarn、pip、curl、wget；
    同时允许自定义任意新工具。
    默认代理 127.0.0.1:7890，可通过 -Proxy 修改。

.PARAMETER Tool
    要配置的工具名，支持数组；内置工具直接写名字即可，
    自定义工具需同时给出 -SetCmd 与 -UnsetCmd。

.PARAMETER Proxy
    代理地址，缺省为 http://127.0.0.1:7890

.PARAMETER Unset
    如果给出该开关，则取消代理；否则设置代理。

.PARAMETER SetCmd
    仅对“自定义工具”有效：设置代理时要执行的命令模板。
    用 {proxy} 占位符代表代理地址，例如：
    "mycli config proxy.url {proxy}"

.PARAMETER UnsetCmd
    仅对“自定义工具”有效：取消代理时要执行的命令。

.EXAMPLE
    Set-ToolProxy git npm pip           # 一键把仨工具代理全设上

.EXAMPLE
    Set-ToolProxy scoop -u              # 取消 scoop 代理

.EXAMPLE
    Set-ToolProxy rust -Proxy http://proxy.lan:8080 `
                      -SetCmd "cargo config --global http.proxy {proxy}" `
                      -UnsetCmd "cargo config --global --unset http.proxy"
#>
function Set-ToolProxy {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string[]]$Tool,

        [string]$Proxy = 'http://127.0.0.1:7890',

        [Alias('u')]
        [switch]$unset,

        [string]$SetCmd,   # 仅自定义工具时有效
        [string]$UnsetCmd  # 仅自定义工具时有效
    )

    # 内置工具的配置表
    $builtin = @{
        git   = @{
            Set   = "git config --global http.proxy $Proxy"
            Unset = 'git config --global --unset http.proxy'
        }
        scoop = @{
            Set   = "scoop config proxy 127.0.0.1:7890"
            Unset = 'scoop config rm proxy'
        }
        npm   = @{
            Set   = "npm config set proxy $Proxy"
            Unset = 'npm config delete proxy'
        }
        yarn  = @{
            Set   = "yarn config set proxy $Proxy"
            Unset = 'yarn config delete proxy'
        }
        curl  = @{
            Set   = "setx CURL_CA_BUNDLE `"`""   # 仅示例：实际可写 -x 参数别名
            Unset = "setx CURL_CA_BUNDLE `"`""
            Note  = 'curl 建议用 alias: curl="curl -x {0}" 放入 $PROFILE'
        }
        wget  = @{
            Set   = "setx WGETRC `"`""            # 同理，可用 ~/.wgetrc
            Unset = "setx WGETRC `"`""
            Note  = 'wget 建议用 ~/.wgetrc 写入 "use_proxy = on"'
        }
    }

    foreach ($t in $Tool) {
        Write-Host "`n==> Handling $t" -ForegroundColor Cyan
        try {
            # 1. 内置工具分支
            if ($builtin.ContainsKey($t)) {
                $cmd = if ($Unset) { $builtin[$t].Unset } else { $builtin[$t].Set }
                Invoke-Expression $cmd
                if ($builtin[$t].Note) { Write-Host "NOTE: $($builtin[$t].Note)" -ForegroundColor DarkYellow }
            }
            # 2. 自定义工具分支
            elseif ($PSBoundParameters.ContainsKey('SetCmd') -and
                    $PSBoundParameters.ContainsKey('UnsetCmd')) {
                $template = if ($Unset) { $UnsetCmd } else { $SetCmd }
                $cmd = $template -replace '\{proxy}', $Proxy
                Invoke-Expression $cmd
            }
            else {
                Write-Warning "未知工具 '$t'，请提供 -SetCmd 与 -UnsetCmd 参数"
                continue
            }
            Write-Host "[OK] $t done!" -ForegroundColor Green
        }
        catch {
            Write-Error "[FAIL] $t : $_"
        }
    }
}

Export-ModuleMember -Function Set-ToolProxy