function Enter-Venv {
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

function Exit-Venv {
    <#
    .SYNOPSIS
        退出当前已激活的 Python 虚拟环境。
    .DESCRIPTION
        如果检测到虚拟环境已激活，则调用 deactivate 函数退出；
        否则提示无虚拟环境可退出。
    .EXAMPLE
        Exit-Venv
    #>
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

function New-ApiKey {
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

function Add-JumpFunction {
    <#
    .SYNOPSIS
        为指定目录注册一个全局"跳转函数"，方便在 PowerShell 中快速 cd 到常用路径。

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

    $resolvedPath = (Resolve-Path $Path).Path
    $funcPath = "function:\global:$Name"

    if ((Test-Path $funcPath) -and (-not $Force)) {
        Write-Warning "函数 $Name 已存在，跳过。如需覆盖请加 -Force。"
        return
    }

    # 使用最简洁的方式创建函数
    Invoke-Expression "function global:$Name { Set-Location '$resolvedPath' }"
}

function Set-Symlink {
    <#
    .SYNOPSIS
        创建符号链接（软链接）工具
    
    .DESCRIPTION
        创建指向目标文件或目录的符号链接。支持文件和目录链接，提供强制覆盖选项。
    
    .PARAMETER name
        要创建的符号链接名称（可以是相对或绝对路径）
    
    .PARAMETER target
        目标文件或目录的完整路径
    
    .PARAMETER force
        如果链接名称已存在，强制删除并重新创建
    
    .PARAMETER verbose
        显示详细的操作过程信息
    
    .EXAMPLE
        setsymlink mylink "C:\path\to\target"
        创建名为 mylink 的符号链接指向目标路径
    
    .EXAMPLE
        setsymlink .config "C:\Users\user\.config" -force -verbose
        强制重新创建 .config 链接并显示详细过程
    
    .NOTES
        需要管理员权限才能创建符号链接
        支持相对路径和绝对路径
        自动识别目标是文件还是目录
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true, Position=0, HelpMessage="符号链接名称")]
        [ValidateNotNullOrEmpty()]
        [string]$name,
        
        [Parameter(Mandatory=$true, Position=1, HelpMessage="目标文件或目录路径")]
        [ValidateNotNullOrEmpty()]
        [string]$target,
        
        [Alias("f")]
        [switch]$force
    )
    
    begin {
        # 将相对路径转换为绝对路径
        $name = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($name)
        $target = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($target)
        
        if ($verbose) {
            Write-Host "设置符号链接:" -ForegroundColor Cyan
            Write-Host "  链接名称: $name" -ForegroundColor White
            Write-Host "  目标路径: $target" -ForegroundColor White
        }
    }
    
    process {
        try {
            # 检查目标路径是否存在
            if (-not (Test-Path $target)) {
                Write-Error "❌ 目标路径不存在: $target"
            }
            
            # 获取目标类型（文件或目录）
            $targetItem = Get-Item $target
            $itemType = if ($targetItem.PSIsContainer) { "目录" } else { "文件" }
            
            if ($verbose) {
                Write-Host "  目标类型: $itemType" -ForegroundColor Gray
            }
            
            # 检查是否已存在同名文件/文件夹/链接
            if (Test-Path $name) {
                $existingItem = Get-Item $name
                
                # 检查是否已经是符号链接
                if ($existingItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
                    $existingTarget = $existingItem.Target
                    if ($existingTarget -eq $target) {
                        Write-Host "✅ 符号链接已存在且指向正确目标" -ForegroundColor Green
                    } else {
                        Write-Host "⚠️  符号链接已存在但指向不同目标:" -ForegroundColor Yellow
                        Write-Host "   当前目标: $existingTarget" -ForegroundColor Yellow
                        Write-Host "   新目标:   $target" -ForegroundColor Yellow
                    }
                }
                
                if ($force) {
                    if ($PSCmdlet.ShouldProcess($name, "删除现有项目并创建符号链接")) {
                        Write-Host "🔄 删除现有项目: $name" -ForegroundColor Yellow
                        Remove-Item -Path $name -Recurse -Force -ErrorAction Stop
                    }
                } else {
                    Write-Error "❌ 已存在同名项目: $name (使用 -force 参数覆盖)"
                }
            }
            
            # 确保父目录存在
            $parentDir = Split-Path -Path $name -Parent
            if (-not (Test-Path $parentDir)) {
                if ($PSCmdlet.ShouldProcess($parentDir, "创建父目录")) {
                    New-Item -Path $parentDir -ItemType Directory -Force | Out-Null
                    if ($verbose) {
                        Write-Host "📁 创建父目录: $parentDir" -ForegroundColor Gray
                    }
                }
            }
            
            # 创建符号链接
            if ($PSCmdlet.ShouldProcess("$name -> $target", "创建符号链接")) {
                if ($verbose) {
                    Write-Host "🔗 创建符号链接: $name -> $target" -ForegroundColor Green
                }
                
                New-Item -Path $name -ItemType SymbolicLink -Target $target -Force -ErrorAction Stop
                
                # 验证创建结果
                if (Test-Path $name) {
                    $newLink = Get-Item $name
                    if ($newLink.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
                        Write-Host "✅ 符号链接创建成功" -ForegroundColor Green
                        
                        # 显示链接信息
                        if ($verbose) {
                            $linkInfo = Get-Item $name
                            Write-Host "   链接类型: $(if ($linkInfo.PSIsContainer) {'目录链接'} else {'文件链接'})" -ForegroundColor Gray
                            Write-Host "   创建时间: $($linkInfo.CreationTime)" -ForegroundColor Gray
                        }
                    } else {
                        Write-Error "❌ 创建的项目不是符号链接"
                    }
                } else {
                    Write-Error "❌ 符号链接创建失败: 链接未找到"
                }
            }
        }
        catch [System.UnauthorizedAccessException] {
            Write-Error "❌ 权限不足: 需要以管理员身份运行 PowerShell"
            Write-Host "💡 提示: 右键点击 PowerShell 图标，选择\"以管理员身份运行\"" -ForegroundColor Cyan
        }
        catch {
            Write-Error "❌ 创建符号链接失败: $($_.Exception.Message)"
            Write-Host "💡 提示: 确保目标路径有效，且有足够权限" -ForegroundColor Cyan
        }
    }
    
    end {
        if ($verbose) {
            Write-Host "操作完成" -ForegroundColor Cyan
        }
    }
}

Export-ModuleMember -Function Enter-Venv, Exit-Venv, New-ApiKey, Add-JumpFunction, Set-Symlink
