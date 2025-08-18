Invoke-Expression (&starship init powershell)

# ENVIRONMENT
$env:Path += ";\WorkPlace\...\dosync"

# Function
#### 你能信？普通公司也要高压内部数据安全……
function usefull {
    param(
        [string]$name,
        [switch]$sync
    )
    
    if ($name -eq "up") {
        python '\...\decompression.py'
        if ($sync) {
            Start-Process -WindowStyle Hidden -WorkingDirectory "\WorkPlace\...\dosync" -FilePath ".\syncthing.exe"
        }
    } elseif ($name -eq "down") {
        if ($sync) {
            Remove-Item -Force -Recurse '\WorkPlace\...\dosync'
            Remove-Item -Force -Recurse '\WorkPlace\...\vback'
        } else {
            python '\...\compression.py'
        }
        Clear-History
    } else {
        Write-Host "For what?"
    }
}

#### 快速设置软链接
function setsymlink {
    param(
        [string]$name,
        [string]$target
    )
    New-Item -Path $name -ItemType SymbolicLink -Target $target
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
        [string]$name,
        [switch]$unset
    )
    
    if ($name -eq "git") {
        if ($unset) {
            git config --global --unset http.proxy
        } else {
            git config --global http.proxy http://127.0.0.1:2334
        }
        Write-Host "Done!"
    } elseif ($name -eq "scoop") {
        if ($unset) {
            scoop config rm proxy
        } else {
            scoop config proxy 127.0.0.1:2334
        }
        Write-Host "Done!"
    } else {
        Write-Host "Are you CRAZY?"
    }
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