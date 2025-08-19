Invoke-Expression (&starship init powershell)

# ENVIRONMENT
$env:Path += ";\WorkPlace\...\dosync"

# Function
#### 快速设置软链接
function setsymlink {
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$name,
        [Parameter(Mandatory=$true, Position=1)]
        [string]$target,
        [switch]$force,
        [switch]$verbose
    )
    
    try {
        # 检查目标路径是否存在
        if (-not (Test-Path $target)) {
            Write-Error "目标路径不存在: $target"
            return $false
        }
        
        # 如果已存在同名文件/文件夹，根据-force参数决定是否删除
        if (Test-Path $name) {
            if ($force) {
                if ($verbose) { Write-Host "已存在，正在删除: $name" -ForegroundColor Yellow }
                Remove-Item -Path $name -Recurse -Force
            } else {
                Write-Error "已存在同名文件/文件夹: $name (使用 -force 参数覆盖)"
                return $false
            }
        }
        
        # 创建符号链接
        if ($verbose) { Write-Host "正在创建符号链接: $name -> $target" -ForegroundColor Green }
        $result = New-Item -Path $name -ItemType SymbolicLink -Target $target -Force
        
        if ($verbose) { Write-Host "成功创建符号链接" -ForegroundColor Green }
        return $true
    }
    catch {
        Write-Error "创建符号链接失败: $($_.Exception.Message)"
        return $false
    }
}

#### Scoop检查并更新
function checkscoop {
    scoop update
    $xx = scoop status | Select-String "Everything is ok!"
    if ($xx) {
        Write-Host "$([char]0x1b)[35;1mEverything of scoop is ok!$([char]0x1b)[0m"
    } else {
        sudo scoop update -a -g
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

#### 快速打开文件夹

# 打开代码文件夹
function Quickopen-Code {
    explorer 'E:\WorkPlace\00_Coding'
}

# 打开下载文件夹
function Open-Download {
    explorer 'D:\Downloads'
}

# 打开YouTube月报文件夹
function Quickopen-Youtube {
    param(
        [string]$ziel = "data"
    )
    $lmonth = (Get-Date -Format "yyyy-MM-01" | Get-Date).AddDays(-1).ToString("yyyyMM")
    $keypath = "E:\WorkPlace\01_WORKING\03_YouTube"
    if ($ziel -in @("data", "Report")) {
        explorer (Join-Path $keypath $ziel $lmonth)
    } else {
        explorer 'E:\WorkPlace\01_WORKING\03_YouTube\'
    }
}

# 打开结算文件夹
function Quickopen-Jiesuan {
    param(
        [string]$ziel = "y2b",
        [switch]$ok
    )
    $lmonth = (Get-Date -Format "yyyy-MM-01" | Get-Date).AddDays(-1).ToString("yyyyMM")
    $tmonth = Get-Date -Format "yyyyMM"
    $keypath = "E:\WorkPlace\01_WORKING\04_Settlements"
    if ($ziel -in @("y2b", "YSP")) {
        if ($ziel -eq "y2b") {
            if ($ok) {
                explorer (Join-Path $keypath "data" $lmonth)
            } else {
                explorer (Join-Path $keypath "data" "YouTube" $lmonth)
            }
        } else {
            if ($ok) {
                explorer (Join-Path $keypath "央视频" $tmonth)
            } else {
                explorer (Join-Path $keypath "央视频")
            }
        }
    } elseif ($ziel -in @("steam", "epic")) {
        explorer (Join-Path $keypath "data" ($ziel.ToUpper()))
    } else {
        explorer 'E:\WorkPlace\01_WORKING\04_Settlements'
    }
}

# 常用文件夹快捷打开工具
function Quickopen {
    param(
        [switch]$info
    )
    if ($info) {
        Write-Host "qopen ::"
        Write-Host "`t -> `qopen` | 打开当前文件夹"
        Write-Host "`t -> `qopen-code` | 打开代码文件夹"
        Write-Host "`t -> `qopen-download` | 打开下载文件夹"
        Write-Host "`t -> `qopen-jiesuan [y2b，YSP，steam，epic]` | 打开结算工作文件夹"
        Write-Host "`t -> `qopen-youtube [data,Report,null]` | 打开当月youtube月报文件夹"
        Write-Host "`t -> `qopen --help` | 显示帮助"
        Write-Host "`t -> `qopen --info(-i)` | 显示基本信息"
        Write-Host "`n Version 20250416 (C) SidneyZhang<zly@lyzhang.me>"
    } else {
        explorer .
    }
}

# Alias
Set-Alias -Name work -Value "cd 'E:\WorkPlace\01_Working'"
Set-Alias -Name coding -Value "cd 'E:\WorkPlace\00_Coding'"
Set-Alias -Name appdata -Value "cd 'C:\Users\<you>\AppData'"
Set-Alias -Name weeknum -Value { Write-Host (Get-Date -Format "%W") }