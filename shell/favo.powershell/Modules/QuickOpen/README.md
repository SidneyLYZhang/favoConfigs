# QuickOpen PowerShell 模块

一个用于快速打开常用工作文件夹的PowerShell模块，通过简单的命令快速访问常用目录，提高工作效率。

## 📋 功能概述

该模块提供了快速访问以下类型文件夹的功能：
- **代码文件夹** - 开发工作目录
- **下载文件夹** - 浏览器下载目录
- **YouTube工作文件夹** - YouTube数据分析和报告目录
- **结算工作文件夹** - 不同平台的结算相关目录

## 🚀 安装方法

1. 将模块文件夹复制到PowerShell模块目录：
   ```powershell
   # 查看模块目录路径
   $env:PSModulePath -split ';'
   ```

2. 通常可以放在以下任一目录：
   - `Documents\WindowsPowerShell\Modules\`
   - `C:\Program Files\WindowsPowerShell\Modules\`

3. 导入模块：
   ```powershell
   Import-Module QuickOpen
   ```

## 🎯 使用方法

### 基本语法
```powershell
Quickopen [command] [target] [options]
```

### 命令列表

| 命令 | 描述 | 示例 |
|------|------|------|
| `code` | 打开代码工作文件夹 | `Quickopen code` |
| `download` | 打开下载文件夹 | `Quickopen download` |
| `youtube` | 打开YouTube工作文件夹 | `Quickopen youtube [data\|Report]` |
| `jiesuan` | 打开结算工作文件夹 | `Quickopen jiesuan [y2b\|YSP\|steam\|epic]` |
| `help` 或 `-Info` | 显示帮助信息 | `Quickopen help` |
| 无参数 | 打开当前文件夹 | `Quickopen` |

### 详细说明

#### 1. YouTube命令
```powershell
Quickopen youtube           # 打开YouTube主目录
Quickopen youtube data      # 打开当月YouTube数据文件夹
Quickopen youtube Report    # 打开当月YouTube报告文件夹
```

#### 2. 结算命令
```powershell
Quickopen jiesuan y2b              # 打开YouTube结算文件夹
Quickopen jiesuan y2b -Ok          # 打开YouTube已确认结算文件夹
Quickopen jiesuan YSP               # 打开央视频结算文件夹
Quickopen jiesuan YSP -Ok           # 打开央视频当月结算文件夹
Quickopen jiesuan steam             # 打开Steam结算文件夹
Quickopen jiesuan epic              # 打开Epic结算文件夹
```

### 参数说明

- **-Ok**: 用于`jiesuan`命令，打开已确认的结算文件夹
- **-Info**: 显示帮助信息

## 📁 目录结构

模块预设的文件夹路径：

```
E:\WorkPlace\00_Coding               # 代码文件夹
D:\Downloads                         # 下载文件夹
E:\WorkPlace\01_WORKING\03_YouTube  # YouTube主目录
E:\WorkPlace\01_WORKING\04_Settlements # 结算主目录
```

### 自动日期处理

- **YouTube数据/报告**: 自动打开上个月的文件夹（格式：yyyyMM）
- **YouTube结算**: 自动打开上个月的结算文件夹
- **央视频结算**: 自动打开当月的结算文件夹

## 🛠️ 自定义配置

如果需要修改文件夹路径，可以编辑模块文件中的以下函数：

- `Open-CodeFolder()` - 修改代码文件夹路径
- `Open-DownloadFolder()` - 修改下载文件夹路径
- `Open-YoutubeFolder()` - 修改YouTube工作目录
- `Open-JiesuanFolder()` - 修改结算工作目录

## 📊 版本信息

- **版本**: 20250416
- **作者**: Sidney Zhang <zly@lyzhang.me>

## 🔧 故障排除

### 常见问题

1. **模块无法导入**
   ```powershell
   # 检查执行策略
   Get-ExecutionPolicy
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

2. **文件夹无法打开**
   - 检查路径是否存在
   - 确认文件夹权限
   - 验证路径格式是否正确

3. **命令无法识别**
   ```powershell
   # 重新导入模块
   Import-Module QuickOpen -Force
   ```

### 调试方法
```powershell
# 查看模块信息
Get-Module QuickOpen

# 查看函数定义
Get-Command Quickopen -Syntax

# 测试单个函数
Open-CodeFolder
```

## 💡 使用技巧

1. **创建别名**: 为常用命令创建更短的别名
   ```powershell
   Set-Alias qo Quickopen
   Set-Alias qc { Quickopen code }
   ```

2. **添加到PowerShell配置文件**: 让模块自动加载
   ```powershell
   # 添加到 $PROFILE
   Import-Module QuickOpen
   ```

3. **结合其他工具**: 可以与文件管理器、IDE等工具配合使用

---

**最后更新**: 2025年8月19日