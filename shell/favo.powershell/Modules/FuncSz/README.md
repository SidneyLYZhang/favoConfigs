# FuncSz PowerShell 模块

这是一个实用的 PowerShell 模块，提供了日常开发中常用的便捷功能。

## 功能介绍

### 1. Python 虚拟环境管理

#### Enter-Venv
自动查找并激活当前目录下的 Python 虚拟环境。

- **智能查找**：自动搜索常见的虚拟环境目录名（venv、.venv、env、.env、virtualenv）
- **一键创建**：如果未找到虚拟环境，可快速创建新的虚拟环境
- **跨平台支持**：自动适配 Windows 和 Linux/macOS 的激活脚本路径
- **强制重建**：支持强制删除并重新创建虚拟环境

**使用示例：**
```powershell
# 自动查找并激活虚拟环境
Enter-Venv

# 指定虚拟环境目录名
Enter-Venv -VenvDir .venv

# 强制重新创建虚拟环境
Enter-Venv -Force
```

#### Exit-Venv
退出当前已激活的 Python 虚拟环境。

**使用示例：**
```powershell
Exit-Venv
```

### 2. API 密钥生成

#### New-ApiKey
生成符合安全标准的随机 API 密钥，格式类似于 OpenAI API 密钥。

- **安全随机**：使用加密安全的随机数生成器
- **可定制**：支持自定义前缀、长度和生成数量
- **批量生成**：可一次性生成多个密钥
- **灵活格式**：可选择是否包含前缀

**使用示例：**
```powershell
# 生成默认格式密钥 (sk- 前缀 + 64位随机字符)
New-ApiKey

# 生成5个32位长度的密钥
New-ApiKey -Length 32 -Count 5

# 生成无前缀的48位密钥
New-ApiKey -NoPrefix -Length 48
```

### 3. 目录跳转功能

#### Add-JumpFunction
为指定目录注册一个全局"跳转函数"，方便在 PowerShell 中快速 cd 到常用路径。

- **快速跳转**：创建一个全局函数，调用即可立即跳转到目标目录
- **路径解析**：自动将相对路径解析为绝对路径，避免后续失效
- **冲突处理**：同名函数已存在时可选择覆盖或保留
- **灵活配置**：支持强制覆盖已有函数

**使用示例：**
```powershell
# 为项目目录创建跳转函数
Add-JumpFunction -Name proj -Path 'C:\Code\MyProject'

# 使用跳转函数
proj              # 立即跳转到 C:\Code\MyProject

# 强制覆盖已存在的同名函数
Add-JumpFunction -Name proj -Path 'D:\NewProject' -Force
```

## 安装使用

1. 将模块文件放置在 PowerShell 模块目录下
2. 导入模块：`Import-Module FuncSz`
3. 开始使用上述功能

## 要求

- PowerShell 5.1 或更高版本
- Python（用于虚拟环境功能）