Invoke-Expression (&starship init powershell)

# ENVIRONMENT
$env:Path += ";\WorkPlace\...\dosync"

# Function
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

# 定义快速打开的函数设定
$GoMap = @{
    code = "E:\WorkPlace\00_CODING"
    work = "E:\WorkPlace\01_WORKING"
    mygit = "L:\gitcoding"
    report = "E:\WorkPlace\01_WORKING\05_ThematicReports\2025"
}

Import-Module FastGo
Set-Alias -Name qopen -Value Invoke-Go