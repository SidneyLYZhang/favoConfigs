# SetProxy PowerShell 模块

一个功能强大的 PowerShell 模块，用于批量设置和管理开发工具的 HTTP/HTTPS 代理配置。

## 功能特性

✅ **支持主流开发工具**:
- Git (HTTP 和 HTTPS 代理)
- NPM (HTTP 和 HTTPS 代理) 
- Yarn (HTTP 和 HTTPS 代理)
- Scoop

✅ **环境变量代理支持**:
- 查看环境变量代理设置
- 支持多种开发工具的环境变量代理检测
- 包括 Stack、Cargo、pip、Docker、Go 等

✅ **智能代理设置**:
- 同时支持 HTTP 和 HTTPS 代理设置
- 可分别为 HTTP 和 HTTPS 指定不同代理地址
- 智能识别工具类型并应用相应配置

✅ **强大的自定义能力**:
- 支持自定义工具配置
- 灵活的占位符系统 (`{proxy}`, `{http_proxy}`, `{https_proxy}`)
- 支持复杂的配置命令

✅ **友好的用户体验**:
- 清晰的彩色输出
- 详细的错误处理
- 状态查看功能
- 支持批量操作

## 安装

1. 将模块文件复制到 PowerShell 模块目录：
```powershell
# 查看模块路径
$env:PSModulePath -split ';'

# 通常复制到用户模块目录
Copy-Item -Path ".\SetProxy" -Destination "$HOME\Documents\PowerShell\Modules" -Recurse -Force
```

2. 导入模块：
```powershell
Import-Module SetProxy
```

## 使用方法

### 基本用法

```powershell
# 为所有工具设置代理
Set-ToolProxy git, npm, scoop

# 使用默认代理 (http://127.0.0.1:7890)
Set-ToolProxy git, npm

# 指定自定义代理地址
Set-ToolProxy git, npm -Proxy "http://proxy.example.com:8080"
```

### 高级用法

```powershell
# 设置不同的 HTTP 和 HTTPS 代理
Set-ToolProxy git -Proxy "http://127.0.0.1:7890" -HttpsProxy "https://127.0.0.1:8443"

# 取消特定工具的代理
Set-ToolProxy npm -Unset

# 批量取消代理
Set-ToolProxy git, npm, cargo -Unset

# 自定义工具配置
Set-ToolProxy mytool `
    -SetCmd "mytool config http.proxy {http_proxy} && mytool config https.proxy {https_proxy}" `
    -UnsetCmd "mytool config --unset http.proxy && mytool config --unset https.proxy"
```

### 查看状态

```powershell
# 查看所有工具的代理状态
Get-ToolProxy

# 查看特定工具的状态
Get-ToolProxy git, npm

# 列出支持的工具
Set-ToolProxy -ListSupported

# 查看环境变量代理设置
Get-EnvProxy

# 查看支持环境变量代理的工具列表
Get-EnvProxy -SupportedTools

# 检查特定的环境变量
Get-EnvProxy HTTP_PROXY, HTTPS_PROXY
```

## 支持的占位符

在自定义命令中，可以使用以下占位符：

- `{proxy}` - 主要代理地址 (通常是 HTTP 代理)
- `{http_proxy}` - HTTP 代理地址
- `{https_proxy}` - HTTPS 代理地址

## 各工具配置详情

### Git
- 设置: `git config --global http.proxy` 和 `git config --global https.proxy`
- 取消: `git config --global --unset http.proxy` 和 `git config --global --unset https.proxy`

### NPM/Yarn
- 设置: `npm/yarn config set proxy` 和 `npm/yarn config set https-proxy`
- 取消: `npm/yarn config delete proxy` 和 `npm/yarn config delete https-proxy`

### Scoop
- 设置: `scoop config proxy`
- 取消: `scoop config rm proxy`

## 示例场景

### 场景 1: 开发环境统一配置
```powershell
# 一键配置所有开发工具
Set-ToolProxy git, npm, scoop
```

### 场景 2: 切换代理服务器
```powershell
# 切换到新的代理服务器
Set-ToolProxy git, npm -Proxy "http://new-proxy:8080"
```

### 场景 3: 临时取消代理
```powershell
# 临时取消 Git 代理
Set-ToolProxy git -Unset

# 稍后重新设置
Set-ToolProxy git
```

### 场景 5: 环境变量代理检测
```powershell
# 查看当前环境变量代理设置
Get-EnvProxy

# 查看支持环境变量代理的所有工具
Get-EnvProxy -SupportedTools

# 检查特定环境变量
Get-EnvProxy GOPROXY, HTTP_PROXY
```

### 场景 4: 企业环境配置
```powershell
# 企业环境通常有不同的 HTTP 和 HTTPS 代理
Set-ToolProxy git, npm -Proxy "http://corp-proxy:8080" -HttpsProxy "https://corp-proxy:8443"
```

## 环境变量代理支持

模块提供了 `Get-EnvProxy` 函数来检查环境变量代理设置，支持以下工具的环境变量代理检测：

### 支持的工具
- **Stack** - Haskell Stack 构建工具
- **Cabal** - Haskell Cabal 包管理器  
- **Cargo** - Rust Cargo 包管理器
- **pip** - Python pip 包管理器
- **Alen** - Alen 包管理器
- **curl** - cURL 命令行工具
- **wget** - Wget 命令行下载工具
- **Docker** - Docker 容器平台
- **Go** - Go 模块代理
- **rustup** - Rust 工具链管理器

### 环境变量
这些工具通常会自动检测以下环境变量：
- `HTTP_PROXY` / `http_proxy` - HTTP 代理
- `HTTPS_PROXY` / `https_proxy` - HTTPS 代理  
- `NO_PROXY` / `no_proxy` - 不需要代理的地址
- `GOPROXY` - Go 模块代理特定设置

### 使用示例

```powershell
# 查看所有环境变量代理设置
Get-EnvProxy

# 查看支持的工具列表
Get-EnvProxy -SupportedTools

# 检查特定环境变量
 Get-EnvProxy HTTP_PROXY, HTTPS_PROXY, GOPROXY
 ```
 
 ## 注意事项
 
 1. **全局配置**: 大多数工具的配置是全局的，会影响所有项目
2. **权限要求**: 某些操作可能需要管理员权限
3. **代理格式**: 确保代理地址格式正确，包含协议头 (http:// 或 https://)

## 故障排除

### 常见问题

1. **命令执行失败**
   - 确保相关工具已正确安装
   - 检查工具是否在系统 PATH 中
   - 验证代理地址是否可访问

2. **Git 配置冲突**
   - 检查是否存在项目级别的 Git 配置
   - 使用 `git config list --global` 查看所有全局配置

### 调试模式

```powershell
# 使用 -Verbose 参数获取详细信息
Set-ToolProxy git -Verbose
```

### 环境变量代理问题

1. **环境变量不生效**
   - 某些工具需要重启才能识别新的环境变量
   - 检查环境变量是否正确设置：`(Get-Item env:HTTP_PROXY).Value`
   - 验证环境变量名称的大小写（某些工具区分大小写）

2. **工具使用环境变量代理但配置失败**
   - 某些工具优先使用环境变量而非配置文件
   - 使用 `Get-EnvProxy` 检查当前环境变量设置
   - 考虑同时设置环境变量和工具特定配置

## 可用函数

模块提供以下三个主要函数：

### Set-ToolProxy
主要功能函数，用于设置或取消开发工具的代理配置。

**主要参数：**
- `-Tool` - 要配置的工具名数组
- `-Proxy` - HTTP 代理地址（默认：http://127.0.0.1:7890）
- `-HttpsProxy` - HTTPS 代理地址
- `-Unset` - 取消代理设置
- `-SetCmd` / `-UnsetCmd` - 自定义工具命令
- `-ListSupported` - 列出支持的工具

### Get-ToolProxy
查看当前已配置的代理设置。

**主要参数：**
- `-Tool` - 要检查的工具名数组（默认检查所有支持的工具）

### Get-EnvProxy
检查环境变量代理设置。

**主要参数：**
- `-Key` - 要检查的特定环境变量名
- `-SupportedTools` - 列出支持环境变量代理的工具

## 许可证

MIT License