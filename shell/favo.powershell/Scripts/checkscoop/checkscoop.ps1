#!/usr/bin/env pwsh
<#
.SYNOPSIS
    检查并更新 Scoop 包管理器

.DESCRIPTION
    此脚本用于检查 Scoop 包管理器的状态并执行必要的更新操作。
    它会首先更新 Scoop 的仓库信息，然后检查是否有可用的更新。
    如果有更新，会提示用户并执行全局更新操作。

.PARAMETER Help
    显示此帮助信息

.PARAMETER Verbose
    显示详细的执行过程信息

.PARAMETER Force
    强制更新所有包，即使状态正常

.PARAMETER NoGlobal
    跳过全局包的更新，只更新用户包

.EXAMPLE
    .\checkscoop.ps1
    检查并更新 Scoop

.EXAMPLE
    .\checkscoop.ps1 -Verbose
    显示详细信息的检查更新

.EXAMPLE
    .\checkscoop.ps1 -Force
    强制更新所有包

.EXAMPLE
    .\checkscoop.ps1 -NoGlobal
    只更新用户包，不更新全局包

.NOTES
    文件名: checkscoop.ps1
    作者: SidneyZhang<zly@lyzhang.me>
    版本: 2.0.0
    创建时间: 2025-03-13
    更新时间: 2025-09-04

.LINK
    https://github.com/SidneyLYZhang/favoConfigs/shell/favo.powershell/Scripts/checkscoop
#>

[CmdletBinding()]
param(
    [Parameter()]
    [Alias("h", "?")]
    [switch]$Help,

    [Parameter()]
    [switch]$Force,

    [Parameter()]
    [switch]$NoGlobal
)

# 显示帮助信息
if ($Help) {
    Get-Help $MyInvocation.MyCommand.Path -Detailed
    exit 0
}

# 检查 Scoop 是否已安装
function Test-ScoopInstalled {
    try {
        $null = Get-Command scoop -ErrorAction Stop
        return $true
    }
    catch {
        Write-Error "Scoop 未安装或未添加到 PATH"
        Write-Host "请访问 https://scoop.sh 了解如何安装 Scoop" -ForegroundColor Yellow
        return $false
    }
}

# 检查管理员权限
function Test-Administrator {
    return ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}

# 主函数
function Update-Scoop {
    [CmdletBinding()]
    param(
        [switch]$Force,
        [switch]$NoGlobal
    )

    try {
        Write-Host "$(Get-Date -Format 'HH:mm:ss') - 开始检查 Scoop 状态..." -ForegroundColor Cyan
        
        # 更新 Scoop 仓库信息
        Write-Verbose "正在更新 Scoop 仓库信息..."
        $updateOutput = scoop update 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            Write-Error "更新仓库信息失败: $updateOutput"
            return $false
        }

        # 检查 Scoop 状态
        Write-Verbose "检查 Scoop 状态..."
        $status = scoop status 6>&1
        
        # 显示当前状态
        if ($VerbosePreference -eq 'Continue') {
            Write-Verbose "当前状态输出:"
            $status | ForEach-Object { Write-Verbose "  $_" }
        }

        # 判断是否需要更新
        $needsUpdate = $status -notmatch "Everything is ok!" -or $Force
        
        if (-not $needsUpdate) {
            Write-Host "✅ $(Get-Date -Format 'HH:mm:ss') - Scoop 状态正常，无需更新" -ForegroundColor Green
            return $true
        } else {
            Write-Host "⚠️  $(Get-Date -Format 'HH:mm:ss') - 检测到需要更新 Scoop 包" -ForegroundColor Yellow
            
            # 更新用户包
            Write-Host "正在更新用户包..." -ForegroundColor Cyan
            $userUpdate = scoop update -a 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-Warning "用户包更新完成，但可能有错误: $userUpdate"
            } else {
                Write-Host "✅ 用户包更新完成" -ForegroundColor Green
            }

            # 更新全局包（如果需要）
            if (-not $NoGlobal) {
                Write-Host "正在检查全局包更新..." -ForegroundColor Cyan
                
                if (-not (Test-Administrator)) {
                    Write-Warning "需要管理员权限更新全局包，请使用管理员模式运行"
                    Write-Host "提示: 右键点击 PowerShell 图标，选择 '以管理员身份运行'" -ForegroundColor Yellow
                } else {
                    Write-Host "正在更新全局包..." -ForegroundColor Cyan
                    $globalUpdate = scoop update -a -g 2>&1
                    if ($LASTEXITCODE -eq 0) {
                        Write-Host "✅ 全局包更新完成" -ForegroundColor Green
                    } else {
                        Write-Error "全局包更新失败: $globalUpdate"
                        return $false
                    }
                }
            } else {
                Write-Host "跳过全局包更新..." -ForegroundColor Yellow
            }

            # 清理旧版本
            Write-Verbose "清理临时数据..."
            scoop cache rm -a 2>&1 | Out-Null
            scoop cleanup * 2>&1 | Out-Null
            
            Write-Host ""
            Write-Host "✅ $(Get-Date -Format 'HH:mm:ss') - Scoop 更新完成" -ForegroundColor Green
            return $true
        }
    }
    catch {
        Write-Error "执行 Scoop 检查时发生错误: $($_.Exception.Message)"
        Write-Verbose "错误详情: $($_.Exception)"
        return $false
    }
}

# 主程序
if (-not (Test-ScoopInstalled)) {
    exit 1
}

# 执行更新
$result = Update-Scoop -Force:$Force -NoGlobal:$NoGlobal -Verbose:$VerbosePreference

if ($result) {
    Write-Host "`n🎉 Scoop 检查更新完成！" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n❌ Scoop 检查更新失败！" -ForegroundColor Red
    exit 1
}