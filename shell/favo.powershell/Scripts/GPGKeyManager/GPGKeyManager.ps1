# GPG密钥管理脚本
# 功能：导出GPG密钥和导入指定文件夹下的密钥

param(
    [Parameter(Mandatory=$false)]
    [string]$Action,  # 操作类型：export 或 import
    
    [Parameter(Mandatory=$false)]
    [string]$KeyID,   # 要导出的密钥ID
    
    [Parameter(Mandatory=$false)]
    [string]$Path = ".\GPG_Keys\"  # 密钥存储路径，默认为当前目录下的GPG_Keys文件夹
)

# 显示帮助信息
function Show-Help {
    Write-Host "GPG密钥管理脚本" -ForegroundColor Green
    Write-Host "使用方法:" -ForegroundColor Yellow
    Write-Host "  .\GPGKeyManager.ps1 -Action export -KeyID <密钥ID> -Path <导出路径>" -ForegroundColor Cyan
    Write-Host "  .\GPGKeyManager.ps1 -Action import -Path <导入路径>" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "参数说明:" -ForegroundColor Yellow
    Write-Host "  -Action: 操作类型 (export - 导出, import - 导入)" -ForegroundColor White
    Write-Host "  -KeyID:  要导出的密钥ID (仅导出时需要)" -ForegroundColor White
    Write-Host "  -Path:   密钥存储路径 (默认为 .\GPG_Keys\)" -ForegroundColor White
    Write-Host ""
    Write-Host "示例:" -ForegroundColor Yellow
    Write-Host "  导出密钥: .\GPGKeyManager.ps1 -Action export -KeyID ABC12345 -Path C:\MyKeys\" -ForegroundColor Cyan
    Write-Host "  导入密钥: .\GPGKeyManager.ps1 -Action import -Path C:\MyKeys\" -ForegroundColor Cyan
}

# 检查GPG是否安装
function Test-GPGInstallation {
    try {
        $gpgVersion = gpg --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "检测到GPG安装: $($gpgVersion | Select-Object -First 1)" -ForegroundColor Green
            return $true
        }
    }
    catch {
        Write-Host "错误: 未找到GPG安装。请确保已安装GnuPG。" -ForegroundColor Red
        return $false
    }
}

# 导出GPG密钥
function Export-GPGKey {
    param(
        [string]$KeyID,
        [string]$ExportPath
    )
    
    # 创建导出目录（如果不存在）
    if (-not (Test-Path $ExportPath)) {
        New-Item -ItemType Directory -Path $ExportPath -Force | Out-Null
        Write-Host "创建目录: $ExportPath" -ForegroundColor Green
    }
    
    # 构建文件路径
    $publicKeyFile = Join-Path $ExportPath "public_key_$KeyID.asc"
    $privateKeyFile = Join-Path $ExportPath "private_key_$KeyID.asc"
    $revocationCertFile = Join-Path $ExportPath "revocation_cert_$KeyID.asc"
    
    Write-Host "正在导出密钥: $KeyID" -ForegroundColor Yellow
    
    try {
        # 导出公钥
        Write-Host "导出公钥..." -ForegroundColor Cyan
        gpg --armor --export $KeyID > $publicKeyFile
        if ($LASTEXITCODE -eq 0) {
            Write-Host "公钥已导出到: $publicKeyFile" -ForegroundColor Green
        } else {
            Write-Host "公钥导出失败" -ForegroundColor Red
        }
        
        # 导出私钥
        Write-Host "导出私钥..." -ForegroundColor Cyan
        gpg --armor --export-secret-keys $KeyID > $privateKeyFile
        if ($LASTEXITCODE -eq 0) {
            Write-Host "私钥已导出到: $privateKeyFile" -ForegroundColor Green
        } else {
            Write-Host "私钥导出失败" -ForegroundColor Red
        }
        
        # 导出撤销证书（如果存在）
        Write-Host "尝试导出撤销证书..." -ForegroundColor Cyan
        gpg --armor --gen-revoke $KeyID > $revocationCertFile 2>$null
        if ($LASTEXITCODE -eq 0 -and (Get-Item $revocationCertFile).Length -gt 0) {
            Write-Host "撤销证书已导出到: $revocationCertFile" -ForegroundColor Green
        } else {
            Remove-Item $revocationCertFile -ErrorAction SilentlyContinue
            Write-Host "未找到撤销证书或导出失败" -ForegroundColor Yellow
        }
        
        Write-Host "密钥导出完成！" -ForegroundColor Green
        
    } catch {
        Write-Host "导出过程中发生错误: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 导入GPG密钥
function Import-GPGKeys {
    param(
        [string]$ImportPath
    )
    
    if (-not (Test-Path $ImportPath)) {
        Write-Host "错误: 路径 $ImportPath 不存在" -ForegroundColor Red
        return
    }
    
    Write-Host "正在从 $ImportPath 导入密钥..." -ForegroundColor Yellow
    
    # 获取所有.asc文件
    $keyFiles = Get-ChildItem -Path $ImportPath -Filter "*.asc" -File
    
    if ($keyFiles.Count -eq 0) {
        Write-Host "未找到任何.asc密钥文件" -ForegroundColor Yellow
        return
    }
    
    foreach ($file in $keyFiles) {
        try {
            Write-Host "导入文件: $($file.Name)" -ForegroundColor Cyan
            gpg --import $file.FullName
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "成功导入: $($file.Name)" -ForegroundColor Green
            } else {
                Write-Host "导入失败: $($file.Name)" -ForegroundColor Red
            }
            
        } catch {
            Write-Host "导入过程中发生错误: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    Write-Host "密钥导入完成！" -ForegroundColor Green
    Write-Host "当前密钥列表:" -ForegroundColor Yellow
    gpg --list-keys
}

# 列出所有密钥
function Show-KeyList {
    Write-Host "当前系统中的GPG密钥:" -ForegroundColor Yellow
    gpg --list-keys
}

# 主程序
Write-Host "=== GPG密钥管理脚本 ===" -ForegroundColor Magenta
Write-Host ""

# 检查GPG安装
if (-not (Test-GPGInstallation)) {
    exit 1
}

# 显示当前密钥列表
Show-KeyList
Write-Host ""

# 根据参数执行相应操作
switch ($Action.ToLower()) {
    "export" {
        if ([string]::IsNullOrEmpty($KeyID)) {
            Write-Host "错误: 导出操作需要指定KeyID参数" -ForegroundColor Red
            Write-Host "请使用 -KeyID 参数指定要导出的密钥ID" -ForegroundColor Yellow
            exit 1
        }
        Export-GPGKey -KeyID $KeyID -ExportPath $Path
    }
    "import" {
        Import-GPGKeys -ImportPath $Path
    }
    default {
        Write-Host "未指定有效操作或显示帮助信息" -ForegroundColor Yellow
        Show-Help
        
        # 交互式菜单
        Write-Host "`n请选择操作:" -ForegroundColor Yellow
        Write-Host "1. 导出密钥" -ForegroundColor Cyan
        Write-Host "2. 导入密钥" -ForegroundColor Cyan
        Write-Host "3. 退出" -ForegroundColor Cyan
        
        $choice = Read-Host "请输入选择 (1-3)"
        
        switch ($choice) {
            "1" {
                $keyIdInput = Read-Host "请输入要导出的密钥ID"
                $pathInput = Read-Host "请输入导出路径 (默认为 .\GPG_Keys\)"
                if ([string]::IsNullOrEmpty($pathInput)) {
                    $pathInput = ".\GPG_Keys\"
                }
                Export-GPGKey -KeyID $keyIdInput -ExportPath $pathInput
            }
            "2" {
                $pathInput = Read-Host "请输入导入路径 (默认为 .\GPG_Keys\)"
                if ([string]::IsNullOrEmpty($pathInput)) {
                    $pathInput = ".\GPG_Keys\"
                }
                Import-GPGKeys -ImportPath $pathInput
            }
            "3" { exit }
            default { Write-Host "无效选择" -ForegroundColor Red }
        }
    }
}