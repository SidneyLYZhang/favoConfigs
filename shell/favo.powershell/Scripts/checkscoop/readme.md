# CheckScoop - Scoop 包管理器检查更新工具

一个用于自动检查并更新 [Scoop](https://scoop.sh) 包管理器的 PowerShell 脚本。
而且这是一个十分简单的更新脚本，安装scoop，并安装有一些软件之后，才需要这个脚本。

## 功能

- ✅ 检查 Scoop 是否已安装
- ✅ 更新 Scoop 仓库信息
- ✅ 检查并更新用户包
- ✅ 检查并更新全局包（需要管理员权限）
- ✅ 自动清理缓存和旧版本
- ✅ 提供详细日志输出

## 使用方法

### 基本用法

把文件拷贝到 `C:\Users\{你的用户名}\Documents\PowerShell\Scripts\` 目录下，即可使用。

```powershell
checkscoop
```

需要使用管理员权限运行：
```powershell
sudo pwsh -Command checkscoop
```

### 参数选项

| 参数 | 说明 | 示例 |
|------|------|------|
| `-Help` / `-h` / `-?` | 显示详细帮助信息 | `.\checkscoop.ps1 -Help` |
| `-Verbose` | 显示详细执行过程 | `.\checkscoop.ps1 -Verbose` |
| `-Force` | 强制更新所有包 | `.\checkscoop.ps1 -Force` |
| `-NoGlobal` | 跳过全局包更新 | `.\checkscoop.ps1 -NoGlobal` |

## 运行要求

- **操作系统**: Windows
- **PowerShell**: 5.1 或更高版本
- **Scoop**: 需要预先安装

## 安装 Scoop

如果尚未安装 Scoop，请访问 [https://scoop.sh](https://scoop.sh) 获取安装指南。

## 管理员权限

更新全局包时需要管理员权限。如果脚本检测到需要更新全局包但当前没有管理员权限，会提示用户使用管理员模式重新运行。

## 输出说明

- ✅ 绿色标记: 操作成功完成
- ⚠️ 黄色标记: 需要注意的警告信息
- ❌ 红色标记: 操作失败