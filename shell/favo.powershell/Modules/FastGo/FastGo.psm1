<#
.SYNOPSIS
    FastGo 模块 - 快速目录导航工具

.DESCRIPTION
    提供快速跳转到常用目录的功能，支持自定义目录映射。
    用户可以在 PowerShell 配置文件中重载 $GoMap 字典来自定义目录映射。

.EXAMPLE
    Import-Module FastGo
    Fast-Go docs    # 跳转到文档目录
    Fast-Go work    # 跳转到工作目录
    Fast-Go .       # 跳转到当前目录
    Fast-Go D:\Projects # 跳转到指定路径

.NOTES
    自定义目录映射方法：
    在 PowerShell 配置文件 ($PROFILE) 中添加：
    $GoMap = @{
        docs = "$HOME\Documents"
        work = "D:\Work"
        myproject = "C:\MyProjects"
    }
    Import-Module FastGo
#>

# 检查是否已存在用户自定义的 $GoMap，如果不存在则使用默认值
if (-not (Test-Path variable:Global:GoMap)) {
    $script:GoMap = @{
        docs   = "$HOME\Documents"
        work   = "D:\Workplace"
        home  = "$HOME"
        temp   = "$env:TEMP"
    }
} else {
    # 使用用户定义的 $GoMap
    $script:GoMap = $Global:GoMap
}

<#
.SYNOPSIS
    快速跳转到指定目录

.DESCRIPTION
    根据提供的参数快速跳转到对应目录，支持预定义的快捷方式、绝对路径和相对路径。

.PARAMETER Target
    目标目录的快捷方式名称或路径。如果为空，则跳转到当前目录。

.PARAMETER NoExplorer
    如果指定此开关，则在当前PowerShell会话中切换目录而不是在资源管理器中打开目录。

.EXAMPLE
    Fast-Go docs
    跳转到文档目录

.EXAMPLE
    Fast-Go work
    在资源管理器中打开工作目录

.EXAMPLE
    Fast-Go work -NoExplorer
    在当前PowerShell会话中切换到工作目录

.EXAMPLE
    Fast-Go D:\Projects\MyProject
    跳转到指定的绝对路径

.EXAMPLE
    Fast-Go ..\..
    跳转到上级目录的上级目录
#>
function Invoke-Go {
    [CmdletBinding(DefaultParameterSetName = 'none')]
    param(
        # 子命令或路径
        [Parameter(Position = 0)]
        [string]$Target,

        # 不使用资源管理器打开
        [switch]$NoExplorer
    )

    try {
        # 1) 无参数 → 显示当前目录
        if ([string]::IsNullOrWhiteSpace($Target)) {
            Write-Host "当前目录: $(Get-Location)" -ForegroundColor Green
            return
        }

        # 2) 子命令 → 查表
        if ($script:GoMap.ContainsKey($Target)) {
            $targetPath = $script:GoMap[$Target]
            Open-Folder -Path $targetPath -NoExplorer:$NoExplorer
            return
        }

        # 3) 绝对/相对路径
        try {
            $resolved = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Target)
            Open-Folder -Path $resolved -NoExplorer:$NoExplorer
        }
        catch {
            Write-Error "无法解析路径 '$Target': $($_.Exception.Message)"
        }
    }
    catch {
        Write-Error "执行 Fast-Go 时发生错误: $($_.Exception.Message)"
    }
}

<#
.SYNOPSIS
    打开指定路径的目录

.DESCRIPTION
    根据参数在资源管理器中打开目录或切换到该目录。

.PARAMETER Path
    要打开的目录路径

.PARAMETER NoExplorer
    如果为 $true，则切换到该目录

.EXAMPLE
    Open-Folder -Path "C:\Windows" -NoExplorer
    切换到 Windows 目录
#>
function Open-Folder {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        
        [Parameter()]
        [switch]$NoExplorer
    )

    if (-not (Test-Path -Path $Path -PathType Container)) {
        Write-Error "目录不存在：$Path"
        return
    }

    try {
        $fullPath = Convert-Path -Path $Path
        
        if ($NoExplorer) {
            Set-Location -Path $fullPath
        }
        else {
            Start-Process explorer.exe -ArgumentList "`"$fullPath`""
        }
    }
    catch {
        Write-Error "打开目录时发生错误: $($_.Exception.Message)"
    }
}

<#
.SYNOPSIS
    获取当前的目录映射表

.DESCRIPTION
    显示当前 FastGo 模块中使用的所有目录映射

.EXAMPLE
    Get-GoMap
    显示所有预定义的目录映射
#>
function Get-GoMap {
    [CmdletBinding()]
    param()

    return $script:GoMap
}

<#
.SYNOPSIS
    添加或更新目录映射

.DESCRIPTION
    向当前会话的目录映射中添加新的快捷方式或更新现有快捷方式

.PARAMETER Key
    快捷方式名称

.PARAMETER Path
    对应的目录路径

.EXAMPLE
    Set-GoMap -Key "project" -Path "C:\MyProjects\Current"
    添加或更新 project 快捷方式
#>
function Set-GoMap {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Key,
        
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -Path $Path -PathType Container)) {
        Write-Error "目录不存在：$Path"
        return
    }

    $script:GoMap[$Key] = $Path
    Write-Host "已添加映射: $Key → $Path" -ForegroundColor Green
}

# 导出所有公共函数
Export-ModuleMember -Function Invoke-Go, Open-Folder, Get-GoMap, Set-GoMap