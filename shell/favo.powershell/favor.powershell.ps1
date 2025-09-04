Invoke-Expression (&starship init powershell)

# ENVIRONMENT
$env:Path += ";\WorkPlace\...\dosync"

# Function
#### 快速设置软链接 - 创建符号链接工具
function setsymlink {
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

#### 更新工具-经常很久才用一次
function updatetools {
    rustup update
    cargo install-update --all
    pipx upgrade-all
}

#### 快速设置或取消设置代理
function setconfig {
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateSet("git", "scoop", "npm", "yarn", "pip", "all")]
        [string]$tool,
        [string]$proxy = "127.0.0.1:2334",
        [switch]$unset,
        [switch]$list,
        [switch]$verbose
    )
    
    $proxyUrl = if ($proxy -match "^http://") { $proxy } else { "http://$proxy" }
    $tools = @()
    
    if ($list) {
        Write-Host "支持的代理工具: git, scoop, npm, yarn, pip, all" -ForegroundColor Cyan
        Write-Host "默认代理地址: 127.0.0.1:2334" -ForegroundColor Gray
        return
    }
    
    if ($tool -eq "all") {
        $tools = @("git", "scoop", "npm", "yarn", "pip")
    } else {
        $tools = @($tool)
    }
    
    $results = @()
    
    foreach ($t in $tools) {
        try {
            switch ($t) {
                "git" {
                    if ($unset) {
                        git config --global --unset http.proxy 2>$null
                        git config --global --unset https.proxy 2>$null
                        $results += @{Tool="Git"; Status="已取消"; Message="HTTP/HTTPS代理已移除"}
                        if ($verbose) { Write-Host "✓ Git代理已取消" -ForegroundColor Green }
                    } else {
                        git config --global http.proxy $proxyUrl
                        git config --global https.proxy $proxyUrl
                        $results += @{Tool="Git"; Status="已设置"; Message="代理: $proxyUrl"}
                        if ($verbose) { Write-Host "✓ Git代理已设置: $proxyUrl" -ForegroundColor Green }
                    }
                }
                "scoop" {
                    if ($unset) {
                        scoop config rm proxy 2>$null
                        $results += @{Tool="Scoop"; Status="已取消"; Message="代理已移除"}
                        if ($verbose) { Write-Host "✓ Scoop代理已取消" -ForegroundColor Green }
                    } else {
                        scoop config proxy $proxy
                        $results += @{Tool="Scoop"; Status="已设置"; Message="代理: $proxy"}
                        if ($verbose) { Write-Host "✓ Scoop代理已设置: $proxy" -ForegroundColor Green }
                    }
                }
                "npm" {
                    if ($unset) {
                        npm config delete proxy 2>$null
                        npm config delete https-proxy 2>$null
                        $results += @{Tool="NPM"; Status="已取消"; Message="代理已移除"}
                        if ($verbose) { Write-Host "✓ NPM代理已取消" -ForegroundColor Green }
                    } else {
                        npm config set proxy $proxyUrl
                        npm config set https-proxy $proxyUrl
                        $results += @{Tool="NPM"; Status="已设置"; Message="代理: $proxyUrl"}
                        if ($verbose) { Write-Host "✓ NPM代理已设置: $proxyUrl" -ForegroundColor Green }
                    }
                }
                "yarn" {
                    if ($unset) {
                        yarn config delete proxy 2>$null
                        yarn config delete https-proxy 2>$null
                        $results += @{Tool="Yarn"; Status="已取消"; Message="代理已移除"}
                        if ($verbose) { Write-Host "✓ Yarn代理已取消" -ForegroundColor Green }
                    } else {
                        yarn config set proxy $proxyUrl
                        yarn config set https-proxy $proxyUrl
                        $results += @{Tool="Yarn"; Status="已设置"; Message="代理: $proxyUrl"}
                        if ($verbose) { Write-Host "✓ Yarn代理已设置: $proxyUrl" -ForegroundColor Green }
                    }
                }
                "pip" {
                    if ($unset) {
                        # 检查并移除pip代理配置
                        $pipConfigPath = "$env:APPDATA\pip\pip.ini"
                        if (Test-Path $pipConfigPath) {
                            $content = Get-Content $pipConfigPath -Raw
                            if ($content -match "proxy") {
                                $content = $content -replace "proxy\s*=\s*.*", ""
                                $content | Set-Content $pipConfigPath
                            }
                        }
                        $results += @{Tool="Pip"; Status="已取消"; Message="代理配置已移除"}
                        if ($verbose) { Write-Host "✓ Pip代理已取消" -ForegroundColor Green }
                    } else {
                        pip config set global.proxy $proxyUrl
                        $results += @{Tool="Pip"; Status="已设置"; Message="代理: $proxyUrl"}
                        if ($verbose) { Write-Host "✓ Pip代理已设置: $proxyUrl" -ForegroundColor Green }
                    }
                }
            }
        }
        catch {
            $results += @{Tool=$t.ToUpper(); Status="失败"; Message=$_.Exception.Message}
            Write-Error "$t 代理设置失败: $($_.Exception.Message)"
        }
    }
    
    # 简洁输出
    if (-not $verbose) {
        $results | Format-Table Tool, Status, Message -AutoSize | Out-Host
    }
    
    return $results
}

#### 快速git push
function gitquick {
    param(
        [string]$commits = "auto"
    )

    git add -A
    
    if ($commits -eq "auto") {
        oco
    }
    elseif ($commits -eq "date") {
        $dnow = Get-Date -Format "yyyy-MM-dd"
        git commit -m $dnow
        $currentBranch = git rev-parse --abbrev-ref HEAD
        git push -u origin $currentBranch
    }
    else {
        git commit -m $commits
        $currentBranch = git rev-parse --abbrev-ref HEAD
        git push -u origin $currentBranch
    }
}

#### 数据加密同步
function Sync-push {
    param(
        [string]$folder,
        [switch]$usexfile
    )
    
    if ($usexfile) {
        restic -r rclone:obs:wkup --verbose backup $folder --exclude-file=excludes.txt
    } else {
        restic -r rclone:obs:wkup --verbose backup $folder
    }
}

function Sync-pull {
    param(
        [string]$name,
        [string]$tofolder
    )
    restic -r rclone:obs:wkup restore $name --target $tofolder
}

function Sync-ls {
    param(
        [string]$name
    )
    if (-not $name) {
        restic -r rclone:obs:wkup snapshots
    } else {
        restic -r rclone:obs:wkup ls $name
    }
}

function Sync-rm {
    param(
        [string]$name
    )
    if (-not $name) {
        restic -r rclone:obs:wkup forget --keep-monthly 1 --prune
    } else {
        restic -r rclone:obs:wkup forget $name --prune 
    }
}

function Sync {
    Write-Host "`push` `pull` `ls` `rm` is all your need..."
    restic version
    rclone --version
    Write-Host "DOC : https://restic.readthedocs.io/en/stable/index.html"
}

#### 打开一个管理员级别的Windows Terminal标签页
function Start-AdminTab {
    sudo wt new-tab
}

function Add-JumpFunction {
    param(
        [string]$Name,
        [string]$Path
    )
    
    $functionDef = @"
    function global:$Name {
        Set-Location '$Path'
    }
"@
    Invoke-Expression $functionDef
}

# 定义路径
Add-JumpFunction -Name "coding" -Path "E:\WorkPlace\00_CODING"
Add-JumpFunction -Name "work" -Path "E:\WorkPlace\01_WORKING"
Add-JumpFunction -Name "download" -Path "D:\Downloads"
Add-JumpFunction -Name "mygit" -Path "L:\gitcoding"

# Alias
Set-Alias -Name admintab -Value Start-AdminTab
Set-Alias -Name weeknum -Value { Write-Host (Get-Date -Format "%W") }