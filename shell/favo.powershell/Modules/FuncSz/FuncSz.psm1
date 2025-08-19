<#
.SYNOPSIS
    自动查找并激活当前目录下的 Python 虚拟环境。
.DESCRIPTION
    在当前目录（或指定目录）中搜索常见名称的虚拟环境目录，
    并执行 Activate.ps1。如果找不到，可一键创建。
.PARAMETER Path
    在哪个目录中查找虚拟环境，默认为当前目录。
.PARAMETER VenvDir
    直接指定虚拟环境目录名称（如 ".venv"）。
.PARAMETER Force
    如果虚拟环境已存在，先删除再重新创建。
.EXAMPLE
    Enter-Venv
.EXAMPLE
    Enter-Venv -VenvDir .venv
#>
function Enter-Venv {
    [CmdletBinding()]
    param(
        [string]$Path = (Get-Location).Path,
        [string]$VenvDir,
        [switch]$Force
    )

    $ErrorActionPreference = 'Stop'

    # 1. 确定虚拟环境目录
    if (-not $VenvDir) {
        $possibleNames = 'venv', '.venv', 'env', '.env', 'virtualenv'
        foreach ($n in $possibleNames) {
            $full = Join-Path $Path $n
            if (Test-Path $full) {
                $VenvDir = $n
                break
            }
        }
    }

    $venvPath = Join-Path $Path $VenvDir

    # 2. 如果需要强制创建，或目录不存在
    if ($Force -and (Test-Path $venvPath)) {
        Remove-Item -Recurse -Force $venvPath | Out-Null
    }

    if (-not (Test-Path $venvPath)) {
        Write-Host "未检测到虚拟环境目录 '$VenvDir'。" -ForegroundColor Yellow
        $create = Read-Host "是否立即创建？ (y/n)"
        if ($create -eq 'y') {
            & python -m venv $venvPath
            if (-not $?) {
                Write-Error "创建虚拟环境失败，请确认 python 已在 PATH 中。"
                return
            }
            Write-Host "已创建虚拟环境：$venvPath" -ForegroundColor Green
        } else {
            return
        }
    }

    # 3. 选择激活脚本
    $activateScript = if ($IsWindows -or ($PSEdition -eq 'Desktop')) {
        Join-Path $venvPath "Scripts\Activate.ps1"
    } else {
        Join-Path $venvPath "bin/Activate.ps1"
    }

    if (-not (Test-Path $activateScript)) {
        Write-Error "找不到激活脚本：$activateScript"
        return
    }

    # 4. 激活
    & $activateScript
    Write-Host "已激活虚拟环境：$venvPath" -ForegroundColor Cyan
}

<#
.SYNOPSIS
    退出当前已激活的 Python 虚拟环境。
.DESCRIPTION
    如果检测到虚拟环境已激活，则调用 deactivate 函数退出；
    否则提示无虚拟环境可退出。
.EXAMPLE
    Exit-Venv
#>
function Exit-Venv {
    [CmdletBinding()]
    param()

    # PowerShell 环境下，虚拟环境激活后会定义全局函数 deactivate
    if (Test-Path Function:\deactivate) {
        deactivate
        Write-Host "已退出虚拟环境。" -ForegroundColor DarkGray
    } else {
        Write-Host "当前没有激活的虚拟环境。" -ForegroundColor Yellow
    }
}

<#
.SYNOPSIS
Generates random API keys similar to OpenAI's format.

.DESCRIPTION
This function generates cryptographically secure random API keys with optional prefix.
By default, it generates keys in the format "sk-" followed by 64 random alphanumeric characters.

.PARAMETER Prefix
The prefix to use for the API key. Default is "sk-".

.PARAMETER Length
The length of the random part of the API key. Default is 64.

.PARAMETER Count
The number of API keys to generate. Default is 1.

.PARAMETER NoPrefix
Switch to generate keys without any prefix.

.EXAMPLE
New-ApiKey
Generates a single API key with default settings: "sk-" prefix and 64 random characters.

.EXAMPLE
New-ApiKey -Length 32 -Count 5
Generates 5 API keys with "sk-" prefix and 32 random characters each.

.EXAMPLE
New-ApiKey -NoPrefix -Length 48
Generates a single 48-character API key with no prefix.

.NOTES
Uses cryptographically secure random number generation for better security.
#>
function New-ApiKey {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [Alias('p')]
        [string]$Prefix = "sk-",
        
        [Parameter(Position = 1)]
        [ValidateRange(8, 256)]
        [Alias('l')]
        [int]$Length = 64,
        
        [Parameter(Position = 2)]
        [ValidateRange(1, 100)]
        [Alias('c')]
        [int]$Count = 1,
        
        [switch]$NoPrefix
    )

    begin {
        # 定义有效的字符集（OpenAI API密钥使用的字符）
        $charSet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'.ToCharArray()
        $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    }

    process {
        for ($i = 1; $i -le $Count; $i++) {
            # 创建字节缓冲区来保存随机数据
            $bytes = [byte[]]::new($Length)
            $rng.GetBytes($bytes)
            
            # 将字节转换为字符
            $randomPart = -join (
                $bytes | ForEach-Object {
                    $charSet[$_ % $charSet.Length]
                }
            )
            
            # 根据参数决定是否添加前缀
            if ($NoPrefix) {
                $randomPart
            } else {
                $Prefix + $randomPart
            }
        }
    }

    end {
        $rng.Dispose()
    }
}

<#
.SYNOPSIS
    为指定目录注册一个全局“跳转函数”，方便在 PowerShell 中快速 cd 到常用路径。

.DESCRIPTION
    本函数会在当前会话内创建一个全局函数（以 $Name 命名），
    调用该函数即可立即 Set-Location 到 $Path 指定的目录。
    若同名函数已存在，可选择覆盖或保留原函数。

.PARAMETER Name
    要创建的跳转函数名称，需符合 PowerShell 函数命名规范。

.PARAMETER Path
    目标目录。支持相对路径，最终会被解析为绝对路径。

.PARAMETER Force
    若同名函数已存在，强制覆盖。

.EXAMPLE
    Add-JumpFunction -Name proj -Path 'C:\Code\MyProject'
    proj              # 立即 cd 到 C:\Code\MyProject
#>
function Add-JumpFunction {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory)]
        [ValidateScript({
            if (-not (Test-Path $_ -PathType Container)) {
                throw "目录不存在：$_"
            }
            $true
        })]
        [string]$Path,

        [switch]$Force
    )

    # 解析为绝对路径，避免相对路径在后续调用时失效
    $resolvedPath = (Resolve-Path $Path).Path

    # 检查是否已有同名函数
    if (Test-Path "function:\global:$Name") {
        if (-not $Force) {
            Write-Warning "函数 global:$Name 已存在，跳过。如需覆盖请加 -Force。"
            return
        }
        Write-Verbose "函数 global:$Name 已存在，将被覆盖。"
    }

    # 利用脚本块动态生成函数体；无需字符串拼接，避免引号转义问题
    $scriptBlock = {
        param()
        Set-Location $args[0]
    }.GetNewClosure()

    # 创建函数
    $null = New-Item `
        -Path "function:\global:$Name" `
        -Value {
            param()
            Set-Location $resolvedPath
        } `
        -Force:$Force

    Write-Host "已注册全局函数：global:$Name -> $resolvedPath" -ForegroundColor Green
}

Export-ModuleMember -Function Enter-Venv, Exit-Venv, New-ApiKey, Add-JumpFunction
