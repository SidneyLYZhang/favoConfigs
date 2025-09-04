# 🏠 favoConfigs - 个人配置集合

现在常用Windows了，慢慢喜欢用上PowerShell和NuShell……
顺便也就是好好整理一下我的各种配置文件们……
这些看似无用，其实就是给自己用的省心一点。

"现实如何纷扰，总还是要自己来一步步走过去，和煦阳光带来的诗意，
在夏秋之交，总是明媚舒适的时光，每一日、每一时、每一步，走过来就是新的天地。"

## 📁 仓库结构

### **apps/** - 应用配置管理
配置各种开发工具和包管理器的偏好设置。

- **favo.scoop.md** - Scoop包管理器配置
- **favo.winget.md** - Windows官方包管理器配置
- **favo.rust.md** - Rust开发环境配置
- **favo.opencommit.md** - Git提交规范化配置

### **shell/** - Shell环境配置
终端环境的美化与功能增强，提升命令行使用体验。

#### 终端配置
- **favo.mt.settings.json** - Windows Terminal完整配置
- **favo.nushell/** - NuShell个性化配置
  - `favo.config.nu` - NuShell主配置文件
- **favo.powershell/** - PowerShell模块与脚本
  - `favor.powershell.ps1` - PowerShell主配置文件
  - **Modules/** - 自定义PowerShell模块
    - `FastGo/` - 快速导航模块
    - `FuncSz/` - 功能增强模块
    - `QuickOpen/` - 快速打开工具
  - **Scripts/** - 实用脚本集合
    - `GPGKeyManager/` - GPG密钥管理脚本
    - `checkscoop/` - Scoop状态检查脚本

#### 极简工具配置
- **suckless - dwm/** - 动态窗口管理器
- **suckless - st/** - 简单终端模拟器

### **Python/** - Python脚本与常用包
Python环境配置和实用工具脚本。

- **pipNormal.md** - pip包管理配置
- **Scripts/** - Python实用脚本
  - **Deprecated/** - 已弃用的脚本（存档）
  - **GenFotos/** - 照片处理工具

## 🚀 快速开始

### 1. 克隆仓库
```bash
git clone https://github.com/your-username/favoConfigs.git
cd favoConfigs
```

### 2. 应用配置
根据需要选择对应的配置文件进行应用：

- **PowerShell配置**: 将 `shell/favo.powershell/favor.powershell.ps1` 内容添加到您的 PowerShell profile
- **NuShell配置**: 将 `shell/favo.nushell/favo.config.nu` 链接到您的 NuShell配置目录
- **Windows Terminal**: 将 `shell/favo.mt.settings.json` 导入到Windows Terminal设置中

## 📄 文件说明

| 文件/目录 | 说明 |
|-----------|------|
| `LICENSE` | MIT开源协议 |
| `.gitignore` | Git忽略文件配置 |
| `apps/` | 各应用详细配置和使用说明 |
| `shell/` | Shell环境详细配置文档 |
| `Python/` | Python工具和配置说明 |

## 📅 更新日志

- **2025年9月5日** - 大幅优化PowerShell相关内容
- **2025年9月1日** - 初始版本，整理个人配置文件
- **2025年9月1日** - 优化README文档结构

---
**最后更新：2025年9月4日 17:05**
