# FastGo 模块

FastGo 是一个 PowerShell 模块，用于快速跳转到常用目录。它支持自定义目录映射，让你可以通过简单的命令快速打开常用文件夹。

## 功能特性

- 🚀 快速跳转到预定义目录
- 📁 支持绝对路径和相对路径
- 🗂️ 可在资源管理器中打开目录
- ⚙️ 支持配置文件重载自定义映射
- 📝 完整的帮助文档和示例
- 🎯 运行时动态添加目录映射
- 🔄 支持在当前PowerShell会话中切换目录

## 安装方法

1. 将 `FastGo` 文件夹复制到你的 PowerShell 模块目录：
   ```powershell
   # 查看模块目录
   $env:PSModulePath -split ';'
   ```

2. 导入模块：
   ```powershell
   Import-Module FastGo
   ```

## 使用方法

### 基本用法

```powershell
# 跳转到文档目录（在资源管理器中打开）
Fast-Go docs

# 在当前PowerShell会话中切换到工作目录
Fast-Go work -NoExplorer

# 跳转到绝对路径（在资源管理器中打开）
Fast-Go C:\MyProjects\Project1

# 跳转到相对路径（在资源管理器中打开）
Fast-Go ..\..\AnotherFolder

# 显示当前目录（无参数）
Fast-Go

# 在当前PowerShell会话中切换到绝对路径
Fast-Go C:\MyProjects\Project1 -NoExplorer
```

### 自定义目录映射

#### 方法1：在 PowerShell 配置文件中重载

在你的 PowerShell 配置文件 (`$PROFILE`) 中添加：

```powershell
# 自定义目录映射
$GoMap = @{
    docs = "$HOME\Documents"
    work = "D:\Work"
    repos = "$HOME\source\repos"
    temp = "$env:TEMP"
    myproject = "C:\MyProjects"
    tools = "D:\Tools"
    # 添加更多自定义映射...
}

# 导入模块
Import-Module FastGo
```

#### 方法2：运行时动态添加

```powershell
# 添加新的目录映射
Set-GoMap -Key "project" -Path "C:\MyProjects\CurrentProject"

# 查看所有映射
Get-GoMap

# 使用新映射
Fast-Go project
```

## 默认映射

| 快捷方式 | 默认路径 |
|----------|----------|
| `docs`   | `$HOME\Documents` |
| `work`   | `D:\Workplace` |
| `home`   | `$HOME` |
| `temp`   | `$env:TEMP` |

## 可用函数

- `Invoke-Go` - 主要导航函数
- `Open-Folder` - 打开指定目录
- `Get-GoMap` - 获取当前所有目录映射
- `Set-GoMap` - 添加或更新目录映射

## 示例配置

### 完整配置文件示例

在你的 PowerShell 配置文件 (`$PROFILE`) 中根据你的需要添加相应的字典目录（以下仅为示例）：

```powershell
# FastGo 模块配置
$GoMap = @{
    # 系统目录
    docs = "$HOME\Documents"
    desktop = "$HOME\Desktop"
    downloads = "$HOME\Downloads"
    
    # 工作目录
    work = "D:\Work"
    projects = "D:\Work\Projects"
    
    # 开发目录
    repos = "$HOME\source\repos"
    github = "$HOME\source\repos\github.com"
    
    # 工具目录
    tools = "D:\Tools"
    scripts = "D:\Scripts"
    
    # 临时目录
    temp = "$env:TEMP"
    
    # 自定义目录
    notes = "C:\Users\$env:USERNAME\OneDrive\Notes"
    backup = "D:\Backup"
}

# 导入模块
Import-Module FastGo

# 设置别名（可选）
Set-Alias -Name go -Value Invoke-Go
Set-Alias -Name gomap -Value Get-GoMap
```

你也可以根据需要，添加临时的目录映射：

```powershell
# 临时添加目录映射
Set-GoMap -Key "temp" -Path "C:\Temp"

# 查看所有映射
Get-GoMap

# 使用临时映射
Invoke-Go temp
```

## 故障排除

### 模块未找到
确保模块文件夹在 `$env:PSModulePath` 指定的目录中。

### 路径不存在
检查目标路径是否正确，使用 `Test-Path` 验证：

```powershell
Test-Path "D:\Your\Path"
```

### 权限问题
确保你有权限访问目标目录。

## 更新日志

### v1.2.0 - 2025-08-19
- 添加 `-NoExplorer` 参数支持在当前PowerShell会话中切换目录
- 优化错误处理和路径验证
- 改进路径解析逻辑，支持更复杂的相对路径

### v1.1.0 - 2025-07-16
- 添加完整的函数文档和注释
- 支持在配置文件中重载 $GoMap
- 新增 `Get-GoMap` 和 `Set-GoMap` 管理函数
- 改进错误处理和日志输出
- 添加模块清单文件

### v1.0.0 - 2024-12-12
- 初始版本，基本导航功能