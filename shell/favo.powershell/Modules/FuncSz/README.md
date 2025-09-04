# FuncSz PowerShell 模块

🚀 **FuncSz** 是一个专为开发者设计的 PowerShell 模块，提供了一套实用的日常开发工具集，让开发工作更加高效便捷。

## 🌟 功能特性

### 1. Python 虚拟环境管理

#### `Enter-Venv` - 智能虚拟环境管理
自动发现并激活 Python 虚拟环境，支持一键创建和重建。

**核心功能：**
- 🔍 **智能搜索**：自动查找 `venv`、`.venv`、`env`、`.env`、`virtualenv` 等常见目录
- ⚡ **一键创建**：未找到环境时自动提示创建
- 🔄 **强制重建**：支持删除重建，保持环境干净
- 🖥️ **跨平台**：自动适配 Windows/Linux/macOS 激活脚本

**参数说明：**
- `-Path`：搜索路径（默认当前目录）
- `-VenvDir`：指定虚拟环境目录名
- `-Force`：强制删除重建

**使用示例：**
```powershell
# 智能查找并激活
Enter-Venv

# 指定目录查找
Enter-Venv -Path "D:\Projects\MyApp"

# 使用特定环境名
Enter-Venv -VenvDir ".venv"

# 强制重建环境
Enter-Venv -Force
```

#### `Exit-Venv` - 优雅退出虚拟环境
安全退出当前激活的 Python 虚拟环境。

**使用示例：**
```powershell
Exit-Venv
```

### 2. 安全 API 密钥生成

#### `New-ApiKey` - 企业级密钥生成器
生成符合安全标准的随机 API 密钥，格式兼容 OpenAI 标准。

**核心功能：**
- 🔐 **加密安全**：使用 `System.Security.Cryptography` 生成器
- 🎛️ **完全定制**：支持自定义前缀、长度、数量
- 📦 **批量生成**：一次生成多个密钥
- 🎯 **灵活格式**：可选前缀、自定义分隔符

**参数说明：**
- `-Prefix`：密钥前缀（默认 `sk-`）
- `-Length`：随机字符长度（8-256，默认64）
- `-Count`：生成数量（1-100，默认1）
- `-NoPrefix`：生成无前缀密钥

**使用示例：**
```powershell
# 生成标准格式密钥
New-ApiKey
# 输出: sk-2kK9mNpQrStUvWxYzAbCdEfGhIjKlMnOpQrStUvWxYzAbCdEfGhIjKlMnOp

# 批量生成短密钥
New-ApiKey -Length 32 -Count 3

# 生成自定义前缀密钥
New-ApiKey -Prefix "api_" -Length 48

# 生成干净的无前缀密钥
New-ApiKey -NoPrefix -Length 64
```

### 3. 智能目录跳转

#### `Add-JumpFunction` - 极速目录导航
为常用目录创建全局快捷跳转函数，告别冗长的 cd 命令。

**核心功能：**
- ⚡ **瞬时跳转**：创建全局函数，调用即达
- 🗂️ **路径固化**：自动解析为绝对路径，避免失效
- 🛡️ **冲突保护**：智能检测同名函数冲突
- 🔄 **强制覆盖**：支持更新已有跳转点

**参数说明：**
- `-Name`：跳转函数名称（必需）
- `-Path`：目标目录路径（必需）
- `-Force`：强制覆盖同名函数

**使用示例：**
```powershell
# 创建项目跳转
Add-JumpFunction -Name proj -Path "C:\Code\MyProject"
proj                    # 立即跳转到项目目录

# 创建工作空间跳转
Add-JumpFunction -Name work -Path "$HOME\Documents\Workspace"
work                    # 回家目录工作区

# 强制更新跳转点
Add-JumpFunction -Name proj -Path "D:\NewProject" -Force

# 查看所有跳转函数
Get-ChildItem Function:\ | Where-Object {$_.Name -match '^(proj|work)$'}
```

### 4. 文件系统工具

#### `Set-Symlink` - 专业符号链接管理
创建和管理符号链接（软链接），支持文件和目录链接。

**核心功能：**
- 📁 **双向支持**：同时支持文件和目录链接
- 🛡️ **安全检查**：权限验证和目标存在性检查
- 🔄 **强制重建**：支持覆盖现有链接
- 📊 **详细报告**：创建结果和链接状态反馈

**参数说明：**
- `-name`：链接名称（支持相对/绝对路径）
- `-target`：目标文件或目录路径
- `-force`：强制覆盖现有项目
- `-verbose`：显示详细操作信息

**使用示例：**
```powershell
# 创建目录链接
Set-Symlink -name "config" -target "$HOME\.config"

# 强制重建文件链接
Set-Symlink -name "myapp.exe" -target "C:\Tools\app.exe" -force

# 详细模式创建链接
Set-Symlink -name "workspace" -target "D:\Projects" -verbose

# 批量创建开发环境链接
$links = @{
    "nvim" = "$HOME\AppData\Local\nvim"
    "ssh" = "$HOME\.ssh"
    "gitconfig" = "$HOME\.gitconfig"
}
$links.GetEnumerator() | ForEach-Object {
    Set-Symlink -name $_.Key -target $_.Value
}
```

**注意事项：**
- 需要管理员权限创建符号链接
- 支持相对路径自动解析
- 自动识别目标类型（文件/目录）

## 🚀 快速开始

### 安装方法

#### 手动安装
```powershell
# 1. 克隆或下载模块到 PowerShell 模块目录
$modulePath = "$HOME\Documents\PowerShell\Modules\FuncSz"
New-Item -Path $modulePath -ItemType Directory -Force

# 2. 复制模块文件
Copy-Item "FuncSz.psm1" -Destination $modulePath

# 3. 导入模块
Import-Module FuncSz
```

### 环境要求

**必需组件：**
- PowerShell 5.1 或更高版本（推荐 PowerShell 7+）
- Python 3.6+（用于虚拟环境功能）
- 管理员权限（用于符号链接功能）

**可选组件：**
- Scoop 包管理器（用于更新功能）
- Git（用于版本管理）

### 配置文件示例

创建 `$PROFILE` 配置，实现开机自动加载：

```powershell
# 添加到 PowerShell 配置文件
Import-Module FuncSz

# 设置常用跳转
Add-JumpFunction -Name dev -Path "$HOME\Code"
Add-JumpFunction -Name docs -Path "$HOME\Documents"

# 设置别名
Set-Alias venv Enter-Venv
Set-Alias key New-ApiKey
Set-Alias link Set-Symlink
```

## 📚 使用场景示例

### 场景1：Python 项目快速启动
```powershell
# 进入项目目录
cd D:\Projects\FlaskApp

# 自动激活环境
Enter-Venv

# 安装依赖
pip install -r requirements.txt

# 退出环境
Exit-Venv
```

### 场景2：开发环境初始化
```powershell
# 创建工作目录结构
Add-JumpFunction -Name frontend -Path "D:\Workspace\Frontend"
Add-JumpFunction -Name backend -Path "D:\Workspace\Backend"

# 创建常用配置链接
Set-Symlink -name "vscode" -target "$HOME\.vscode" -verbose

# 生成 API 密钥
$apiKey = New-ApiKey -Length 64
$apiKey | Set-Clipboard
Write-Host "API密钥已复制到剪贴板"
```

## 🔧 故障排除

### 常见问题

**Q: Import-Module 失败**
```powershell
# 检查执行策略
Get-ExecutionPolicy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 验证模块路径
$env:PSModulePath -split ';'
```

**Q: Enter-Venv 找不到 Python**
```powershell
# 检查 Python 路径
python --version
Get-Command python

# 手动指定 Python 路径
$env:PATH += ";C:\Python39\Scripts\;C:\Python39\"
```

**Q: Set-Symlink 权限错误**

可以进一步使用管理员身份再次运行。
```powershell
# 以管理员身份运行 PowerShell
Start-Process powershell -Verb RunAs

# 或启用开发者模式（Windows 10+）
# 设置 -> 更新和安全 -> 开发者选项 -> 开发者模式
sudo Set-Symlink -name "config" -target "$HOME\.config"
```