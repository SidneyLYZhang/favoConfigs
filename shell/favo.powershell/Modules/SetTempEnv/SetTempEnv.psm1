<#
.SYNOPSIS
临时设置环境变量（仅当前会话有效）

.DESCRIPTION
在当前PowerShell会话中临时设置环境变量，不会影响系统或用户环境变量

.PARAMETER Name
环境变量名称

.PARAMETER Value
环境变量值

.PARAMETER WhatIf
显示将要执行的操作而不实际执行

.EXAMPLE
Set-TempEnv -Name "MY_VAR" -Value "test_value"

.EXAMPLE
Set-TempEnv "PATH" "$env:PATH;C:\NewPath"

.OUTPUTS
System.String
返回设置的环境变量信息
#>
function Set-TempEnv {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true, Position=0, HelpMessage="环境变量名称")]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[a-zA-Z_][a-zA-Z0-9_]*$')]
        [string]$Name,
        
        [Parameter(Mandatory=$true, Position=1, HelpMessage="环境变量值")]
        [AllowEmptyString()]
        [string]$Value,
        
        [Parameter(HelpMessage="如果变量已存在是否强制覆盖")]
        [switch]$Force
    )
    
    try {
        Write-Verbose "正在设置临时环境变量: $Name = '$Value'"
        
        # 检查变量是否已存在且未指定Force参数
        if (-not $Force -and (Test-Path "env:$Name")) {
            $existingValue = Get-Content "env:$Name" -ErrorAction SilentlyContinue
            Write-Warning "环境变量 '$Name' 已存在，值为: '$existingValue'. 使用 -Force 参数覆盖."
            return
        }
        
        if ($PSCmdlet.ShouldProcess("环境变量 '$Name'", "设置为值 '$Value'")) {
            # 设置环境变量
            Set-Content -Path "env:$Name" -Value $Value -Force
            
            $message = "✅ 已临时设置 `$env:$Name = '$Value'（仅当前会话有效）"
            Write-Host $message -ForegroundColor Green
            
            # 返回对象信息
            return [PSCustomObject]@{
                Name = $Name
                Value = $Value
                Action = "Set"
                Timestamp = Get-Date
                PSTypeName = 'TempEnv.OperationResult'
            }
        }
    }
    catch {
        Write-Error "设置环境变量失败: $_"
        throw
    }
}

<#
.SYNOPSIS
临时移除环境变量（仅当前会话有效）

.DESCRIPTION
在当前PowerShell会话中临时移除环境变量，不会影响系统或用户环境变量

.PARAMETER Name
环境变量名称，支持通配符

.PARAMETER WhatIf
显示将要执行的操作而不实际执行

.EXAMPLE
Remove-TempEnv -Name "MY_VAR"

.EXAMPLE
Remove-TempEnv -Name "TEST_*"

.EXAMPLE
Remove-TempEnv -Name "TEMP_*" -WhatIf

.OUTPUTS
System.Object[]
返回被移除的环境变量信息数组
#>
function Remove-TempEnv {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true, Position=0, HelpMessage="环境变量名称（支持通配符）")]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        
        [Parameter(HelpMessage="同时移除系统环境变量")]
        [switch]$IncludeSystem
    )
    
    try {
        Write-Verbose "正在查找匹配的临时环境变量: $Name"
        
        # 获取匹配的环境变量
        $matchingVars = Get-ChildItem -Path "env:" -Name $Name -ErrorAction SilentlyContinue
        
        if ($matchingVars.Count -eq 0) {
            Write-Host "⚠️  未找到匹配的环境变量: $Name" -ForegroundColor Yellow
            return
        }
        
        # 如果不包含系统变量，进行过滤
        if (-not $IncludeSystem) {
            $systemVars = (Get-TempEnvSystemVars).Core
            $matchingVars = $matchingVars | Where-Object { $_ -notin $systemVars }
            
            if ($matchingVars.Count -eq 0) {
                Write-Host "ℹ️  未找到非系统环境变量匹配: $Name" -ForegroundColor Cyan
                return
            }
        }
        
        Write-Verbose "找到 $($matchingVars.Count) 个匹配的环境变量"
        $removedVars = @()
        
        foreach ($varName in $matchingVars) {
            $originalValue = Get-Content -Path "env:$varName" -ErrorAction SilentlyContinue
            
            if ($PSCmdlet.ShouldProcess("环境变量 '$varName'", "移除")) {
                try {
                    Remove-Item -Path "env:$varName" -Force -ErrorAction Stop
                    
                    $message = "🗑️  已临时移除 `$env:$varName"
                    Write-Host $message -ForegroundColor DarkYellow
                    
                    $removedVars += [PSCustomObject]@{
                        Name = $varName
                        OriginalValue = $originalValue
                        Action = "Removed"
                        Timestamp = Get-Date
                        PSTypeName = 'TempEnv.OperationResult'
                    }
                }
                catch {
                    Write-Error "移除环境变量 '$varName' 失败: $_"
                }
            }
        }
        
        if ($removedVars.Count -gt 0) {
            Write-Host "✅ 共移除 $($removedVars.Count) 个环境变量" -ForegroundColor Green
        }
        
        return $removedVars
    }
    catch {
        Write-Error "移除环境变量失败: $_"
        throw
    }
}

<#
.SYNOPSIS
获取临时环境变量的信息

.DESCRIPTION
查询当前会话中的临时环境变量，支持通配符匹配和过滤

.PARAMETER Name
环境变量名称，支持通配符。如果省略，返回所有环境变量

.PARAMETER ValuePattern
值匹配模式，支持通配符

.EXAMPLE
Get-TempEnv

.EXAMPLE
Get-TempEnv -Name "MY_*"

.EXAMPLE
Get-TempEnv -ValuePattern "*test*"

.OUTPUTS
System.Object[]
返回环境变量信息对象数组
#>
function Get-TempEnv {
    [CmdletBinding()]
    param(
        [Parameter(Position=0, HelpMessage="环境变量名称（支持通配符）")]
        [string]$Name = "*",
        
        [Parameter(HelpMessage="值匹配模式（支持通配符）")]
        [string]$ValuePattern = "*",
        
        [Parameter(HelpMessage="包含详细系统变量信息")]
        [switch]$Detailed
    )
    
    try {
        Write-Verbose "正在查询环境变量: Name='$Name', ValuePattern='$ValuePattern'"
        
        # 获取匹配的环境变量
        $envVars = Get-ChildItem -Path "env:" -Name $Name -ErrorAction SilentlyContinue |
            Where-Object { (Get-Content "env:$_") -like $ValuePattern }
        
        if ($envVars.Count -eq 0) {
            Write-Verbose "未找到匹配的环境变量"
            return
        }
        
        Write-Verbose "找到 $($envVars.Count) 个匹配的环境变量"
        
        # 定义系统变量列表
        $systemVars = if (-not $Detailed) {
            @(
                "PATH", "TEMP", "TMP", "USERNAME", "USERPROFILE", "HOMEDRIVE", "HOMEPATH",
                "COMPUTERNAME", "OS", "PROCESSOR_ARCHITECTURE", "SYSTEMROOT", "WINDIR",
                "USERDOMAIN", "USERDOMAIN_ROAMINGPROFILE", "LOGONSERVER", "SESSIONNAME",
                "APPDATA", "LOCALAPPDATA", "PROGRAMFILES", "PROGRAMFILES(X86)",
                "COMMONPROGRAMFILES", "COMMONPROGRAMFILES(X86)", "PUBLIC", "COMMONPROGRAMW6432",
                "PROGRAMW6432", "PSMODULEPATH", "PATHEXT", "COMMONPROGRAMW6432"
            )
        } else {
            @()
        }
        
        # 创建输出对象
        $result = foreach ($varName in $envVars) {
            # 跳过系统变量（除非指定了-Detailed）
            if ($varName -in $systemVars) { continue }
            
            $varValue = Get-Content -Path "env:$varName" -ErrorAction SilentlyContinue
            $varType = Get-TempEnvType -Value $varValue
            
            [PSCustomObject]@{
                Name = $varName
                Value = $varValue
                Length = if ($varValue) { $varValue.Length } else { 0 }
                Type = $varType
                IsSystem = $varName -in $systemVars
                Timestamp = (Get-Item "env:$varName").CreationTime
                PSTypeName = 'TempEnv.Variable'
            }
        }
        
        return $result | Sort-Object Name
    }
    catch {
        Write-Error "查询环境变量失败: $_"
        throw
    }
}

<#
.SYNOPSIS
清空所有临时环境变量

.DESCRIPTION
移除当前会话中的所有临时环境变量，可以选择排除某些变量

.PARAMETER Exclude
要排除的环境变量名称数组

.PARAMETER IncludeSystem
是否包含系统环境变量（默认不包含）

.PARAMETER WhatIf
显示将要执行的操作而不实际执行

.EXAMPLE
Clear-TempEnv

.EXAMPLE
Clear-TempEnv -Exclude "PATH", "HOME"

.EXAMPLE
Clear-TempEnv -IncludeSystem -WhatIf

.OUTPUTS
System.Object[]
返回被清空的环境变量信息数组
#>
function Clear-TempEnv {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(HelpMessage="要排除的环境变量名称数组")]
        [string[]]$Exclude = @(),
        
        [Parameter(HelpMessage="是否包含系统环境变量")]
        [switch]$IncludeSystem,
        
        [Parameter(HelpMessage="排除PowerShell特定的环境变量")]
        [switch]$ExcludePowerShell
    )
    
    try {
        Write-Verbose "正在准备清空临时环境变量"
        
        # 获取所有环境变量
        $allVars = Get-ChildItem -Path "env:" -ErrorAction SilentlyContinue
        
        if ($allVars.Count -eq 0) {
            Write-Host "ℹ️  当前没有临时环境变量" -ForegroundColor Cyan
            return
        }
        
        # 获取系统变量列表
        $systemVars = Get-TempEnvSystemVars
        
        # 过滤要排除的变量
        $varsToRemove = $allVars | Where-Object { $_.Name -notin $Exclude }
        
        if (-not $IncludeSystem) {
            $varsToRemove = $varsToRemove | Where-Object { $_.Name -notin $systemVars.Core }
        }
        
        if ($ExcludePowerShell) {
            $varsToRemove = $varsToRemove | Where-Object { $_.Name -notin $systemVars.PowerShell }
        }
        
        if ($varsToRemove.Count -eq 0) {
            Write-Host "ℹ️  没有可清空的环境变量（可能被排除或属于系统变量）" -ForegroundColor Cyan
            return
        }
        
        Write-Verbose "将清空 $($varsToRemove.Count) 个环境变量"
        $clearedVars = @()
        
        if ($PSCmdlet.ShouldProcess("$($varsToRemove.Count) 个环境变量", "清空")) {
            foreach ($var in $varsToRemove) {
                try {
                    $varName = $var.Name
                    $originalValue = $var.Value
                    
                    Remove-Item -Path "env:$varName" -Force -ErrorAction Stop
                    
                    Write-Verbose "已清空环境变量: $varName"
                    
                    $clearedVars += [PSCustomObject]@{
                        Name = $varName
                        OriginalValue = $originalValue
                        Action = "Cleared"
                        Timestamp = Get-Date
                        PSTypeName = 'TempEnv.OperationResult'
                    }
                }
                catch {
                    Write-Error "清空环境变量 '$($var.Name)' 失败: $_"
                }
            }
            
            $message = "🧹 已清空 $($clearedVars.Count) 个临时环境变量"
            Write-Host $message -ForegroundColor Magenta
            
            if ($Exclude.Count -gt 0) {
                Write-Host "📋 排除了以下变量: $($Exclude -join ', ')" -ForegroundColor Gray
            }
            
            if ($IncludeSystem) {
                Write-Host "⚠️  注意：已包含系统环境变量" -ForegroundColor Yellow
            }
        }
        
        return $clearedVars
    }
    catch {
        Write-Error "清空环境变量失败: $_"
        throw
    }
}

<#
.SYNOPSIS
获取环境变量的类型信息

.DESCRIPTION
分析环境变量值并返回其数据类型

.PARAMETER Value
环境变量值

.OUTPUTS
System.String
返回类型名称
#>
function Get-TempEnvType {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]$Value
    )
    
    if ([string]::IsNullOrEmpty($Value)) {
        return 'Empty'
    }
    
    # 检查布尔值
    if ($Value -match '^(true|false)$') {
        return 'Boolean'
    }
    
    # 检查整数
    if ($Value -match '^-?\d+$') {
        return 'Integer'
    }
    
    # 检查浮点数
    if ($Value -match '^-?\d*\.\d+$') {
        return 'Float'
    }
    
    # 检查路径
    if ($Value -match '^[a-zA-Z]:\\|^\\\\|^/|^~') {
        return 'Path'
    }
    
    # 检查URL
    if ($Value -match '^https?://') {
        return 'URL'
    }
    
    # 检查逗号分隔的列表
    if ($Value -match ',') {
        return 'List'
    }
    
    return 'String'
}

<#
.SYNOPSIS
获取系统环境变量列表

.DESCRIPTION
返回系统环境变量的分类列表

.OUTPUTS
System.Collections.Hashtable
包含Core和PowerShell系统变量的哈希表
#>
function Get-TempEnvSystemVars {
    [CmdletBinding()]
    param()
    
    return @{
        Core = @(
            "PATH", "TEMP", "TMP", "USERNAME", "USERPROFILE", "HOMEDRIVE", "HOMEPATH",
            "COMPUTERNAME", "OS", "PROCESSOR_ARCHITECTURE", "SYSTEMROOT", "WINDIR",
            "USERDOMAIN", "USERDOMAIN_ROAMINGPROFILE", "LOGONSERVER", "SESSIONNAME",
            "APPDATA", "LOCALAPPDATA", "PROGRAMFILES", "PROGRAMFILES(X86)",
            "COMMONPROGRAMFILES", "COMMONPROGRAMFILES(X86)", "PUBLIC", "COMMONPROGRAMW6432",
            "PROGRAMW6432", "PSMODULEPATH", "PATHEXT"
        )
        PowerShell = @(
            "PSMODULEPATH", "PSVERSIONTABLE", "PSHOME", "PSMODULEROOT", "PSCONFIGFILE",
            "PSCOMMANDPATH", "PSCULTURE", "PSUICULTURE", "PSDEFAULTPARAMETERVALUES"
        )
    }
}

<#
.SYNOPSIS
备份当前会话的环境变量

.DESCRIPTION
创建当前会话中所有环境变量的备份，可以保存到文件或返回对象

.PARAMETER Path
备份文件路径（可选）

.PARAMETER IncludeSystem
是否包含系统环境变量

.EXAMPLE
Backup-TempEnv

.EXAMPLE
Backup-TempEnv -Path "$env:USERPROFILE\env_backup.json"

.EXAMPLE
Backup-TempEnv -IncludeSystem -Path "./full_env_backup.json"

.OUTPUTS
System.Object[]
返回环境变量备份对象数组
#>
function Backup-TempEnv {
    [CmdletBinding()]
    param(
        [Parameter(HelpMessage="备份文件路径")]
        [string]$Path,
        
        [Parameter(HelpMessage="是否包含系统环境变量")]
        [switch]$IncludeSystem
    )
    
    try {
        Write-Verbose "正在备份环境变量..."
        
        # 获取所有环境变量
        $allVars = Get-ChildItem -Path "env:" -ErrorAction SilentlyContinue
        
        if (-not $IncludeSystem) {
            $systemVars = (Get-TempEnvSystemVars).Core
            $allVars = $allVars | Where-Object { $_.Name -notin $systemVars }
        }
        
        # 创建备份对象
        $backup = @{
            Timestamp = Get-Date
            User = $env:USERNAME
            Computer = $env:COMPUTERNAME
            Variables = @()
        }
        
        $backup.Variables = foreach ($var in $allVars) {
            [PSCustomObject]@{
                Name = $var.Name
                Value = $var.Value
                Type = Get-TempEnvType -Value $var.Value
                PSTypeName = 'TempEnv.BackupVariable'
            }
        }
        
        # 如果指定了路径，保存到文件
        if ($Path) {
            $backup | ConvertTo-Json -Depth 10 | Out-File -FilePath $Path -Encoding UTF8
            Write-Host "✅ 环境变量备份已保存到: $Path" -ForegroundColor Green
        }
        
        Write-Host "📋 已备份 $($backup.Variables.Count) 个环境变量" -ForegroundColor Cyan
        return $backup
    }
    catch {
        Write-Error "备份环境变量失败: $_"
        throw
    }
}

<#
.SYNOPSIS
从备份恢复环境变量

.DESCRIPTION
从备份文件或对象恢复环境变量到当前会话

.PARAMETER Path
备份文件路径

.PARAMETER Backup
备份对象

.PARAMETER WhatIf
显示将要执行的操作而不实际执行

.EXAMPLE
Restore-TempEnv -Path "$env:USERPROFILE\env_backup.json"

.EXAMPLE
$backup = Backup-TempEnv
Restore-TempEnv -Backup $backup

.EXAMPLE
Restore-TempEnv -Path "./backup.json" -WhatIf

.OUTPUTS
System.Object[]
返回恢复的环境变量信息数组
#>
function Restore-TempEnv {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(ParameterSetName="Path", Position=0, Mandatory=$true)]
        [string]$Path,
        
        [Parameter(ParameterSetName="Object", Mandatory=$true)]
        [PSCustomObject]$Backup,
        
        [Parameter(HelpMessage="如果变量已存在是否强制覆盖")]
        [switch]$Force
    )
    
    try {
        # 如果指定了路径，从文件加载备份
        if ($PSCmdlet.ParameterSetName -eq "Path") {
            if (-not (Test-Path $Path)) {
                throw "备份文件不存在: $Path"
            }
            
            $Backup = Get-Content -Path $Path -Raw -Encoding UTF8 | ConvertFrom-Json
        }
        
        Write-Verbose "正在从备份恢复环境变量..."
        Write-Host "📅 备份时间: $($Backup.Timestamp)" -ForegroundColor Gray
        Write-Host "👤 备份用户: $($Backup.User)" -ForegroundColor Gray
        Write-Host "💻 备份计算机: $($Backup.Computer)" -ForegroundColor Gray
        
        $restoredVars = @()
        
        foreach ($var in $Backup.Variables) {
            if ($PSCmdlet.ShouldProcess("环境变量 '$($var.Name)'", "恢复为值 '$($var.Value)'")) {
                try {
                    # 检查变量是否已存在
                    if (-not $Force -and (Test-Path "env:$($var.Name)")) {
                        $existingValue = Get-Content "env:$($var.Name)" -ErrorAction SilentlyContinue
                        Write-Warning "环境变量 '$($var.Name)' 已存在，值为: '$existingValue'. 使用 -Force 参数覆盖."
                        continue
                    }
                    
                    # 恢复环境变量
                    Set-Content -Path "env:$($var.Name)" -Value $var.Value -Force
                    
                    Write-Verbose "已恢复环境变量: $($var.Name) = '$($var.Value)'"
                    
                    $restoredVars += [PSCustomObject]@{
                        Name = $var.Name
                        Value = $var.Value
                        Action = "Restored"
                        Timestamp = Get-Date
                        PSTypeName = 'TempEnv.OperationResult'
                    }
                }
                catch {
                    Write-Error "恢复环境变量 '$($var.Name)' 失败: $_"
                }
            }
        }
        
        $message = "✅ 已恢复 $($restoredVars.Count) 个环境变量"
        Write-Host $message -ForegroundColor Green
        
        return $restoredVars
    }
    catch {
        Write-Error "恢复环境变量失败: $_"
        throw
    }
}

# 设置别名
Set-Alias -Name 'ste' -Value 'Set-TempEnv'
Set-Alias -Name 'gte' -Value 'Get-TempEnv'
Set-Alias -Name 'rte' -Value 'Remove-TempEnv'
Set-Alias -Name 'cte' -Value 'Clear-TempEnv'
Set-Alias -Name 'bte' -Value 'Backup-TempEnv'
Set-Alias -Name 'rste' -Value 'Restore-TempEnv'

Export-ModuleMember -Function Set-TempEnv, Get-TempEnv, Remove-TempEnv, Clear-TempEnv, Backup-TempEnv, Restore-TempEnv, Get-TempEnvType -Alias ste, gte, rte, cte, bte, rste