<#
.SYNOPSIS
快速打开常用文件夹的工具集

.DESCRIPTION
提供一系列快捷命令用于快速访问常用工作文件夹

.VERSION
20250416 (C) SidneyZhang<zly@lyzhang.me>
#>
function Quickopen {
    <#
    .SYNOPSIS
    快速打开常用文件夹的主命令
    
    .DESCRIPTION
    提供子命令用于快速访问不同文件夹
    
    .PARAMETER Command
    要执行的子命令
    
    .PARAMETER Target
    子命令的目标参数
    
    .PARAMETER Info
    显示帮助信息
    
    .EXAMPLE
    Quickopen -Info
    显示帮助信息
    
    .EXAMPLE
    Quickopen code
    打开代码文件夹
    
    .EXAMPLE
    Quickopen jiesuan y2b
    打开YouTube结算文件夹
    #>
    [CmdletBinding(DefaultParameterSetName='Default')]
    param(
        [Parameter(Position=0, ParameterSetName='Command')]
        [ValidateSet('code', 'download', 'youtube', 'jiesuan', 'help')]
        [string]$Command,
        
        [Parameter(Position=1, ParameterSetName='Command')]
        [string]$Target,
        
        [Parameter(ParameterSetName='Command')]
        [switch]$Ok,
        
        [Parameter(ParameterSetName='Info')]
        [Alias('i')]
        [switch]$Info
    )
    
    if ($PSCmdlet.ParameterSetName -eq 'Info' -or $Command -eq 'help') {
        Show-QuickopenHelp
        return
    }
    
    switch ($Command) {
        'code'      { Open-CodeFolder }
        'download'  { Open-DownloadFolder }
        'youtube'   { Open-YoutubeFolder -Target $Target }
        'jiesuan'   { Open-JiesuanFolder -Target $Target -Ok:$Ok }
        default     { explorer . }
    }
}

# 内部函数 - 显示帮助信息
function Show-QuickopenHelp {
    Write-Host "Quickopen :: 常用文件夹快捷打开工具"
    Write-Host ""
    Write-Host "用法:"
    Write-Host "`tQuickopen [command] [options]"
    Write-Host ""
    Write-Host "命令:"
    Write-Host "`t无参数         打开当前文件夹"
    Write-Host "`tcode           打开代码文件夹"
    Write-Host "`tdownload       打开下载文件夹"
    Write-Host "`tyoutube [data|Report] 打开当月YouTube月报文件夹"
    Write-Host "`tjiesuan [y2b|YSP|steam|epic] 打开结算工作文件夹"
    Write-Host "`thelp 或 -Info  显示此帮助信息"
    Write-Host ""
    Write-Host "选项:"
    Write-Host "`t-Ok            用于jiesuan命令，打开已确认的文件夹"
    Write-Host ""
    Write-Host "Version 20250416 (C) SidneyZhang<zly@lyzhang.me>"
}

# 内部函数 - 打开代码文件夹
function Open-CodeFolder {
    explorer 'E:\WorkPlace\00_Coding'
}

# 内部函数 - 打开下载文件夹
function Open-DownloadFolder {
    explorer 'D:\Downloads'
}

# 内部函数 - 打开YouTube文件夹
function Open-YoutubeFolder {
    param(
        [string]$Target = "data"
    )
    
    $lmonth = (Get-Date -Format "yyyy-MM-01" | Get-Date).AddDays(-1).ToString("yyyyMM")
    $keypath = "E:\WorkPlace\01_WORKING\03_YouTube"
    
    if ($Target -in @("data", "Report")) {
        explorer (Join-Path $keypath $Target $lmonth)
    } else {
        explorer $keypath
    }
}

# 内部函数 - 打开结算文件夹
function Open-JiesuanFolder {
    param(
        [string]$Target = "y2b",
        [switch]$Ok
    )
    
    $lmonth = (Get-Date).AddMonths(-1).ToString("yyyyMM")
    $tmonth = Get-Date -Format "yyyyMM"
    $keypath = "E:\WorkPlace\01_WORKING\04_Settlements"
    
    switch ($Target) {
        "y2b" {
            if ($Ok) {
                explorer (Join-Path $keypath "data" $lmonth)
            } else {
                explorer (Join-Path $keypath "data" "YouTube" $lmonth)
            }
        }
        "YSP" {
            if ($Ok) {
                explorer (Join-Path $keypath "央视频" $tmonth)
            } else {
                explorer (Join-Path $keypath "央视频")
            }
        }
        {$_ -in @("steam", "epic")} {
            explorer (Join-Path $keypath "data" ($_.ToUpper()))
        }
        default {
            explorer $keypath
        }
    }
}

# 导出模块命令
Export-ModuleMember -Function Quickopen