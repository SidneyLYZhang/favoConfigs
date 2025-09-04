# GPG密钥管理器 - PowerShell脚本

## 简介

这是一个用于管理GPG密钥的PowerShell脚本，支持密钥的导出和导入功能。脚本提供了命令行参数和交互式菜单两种使用方式，方便用户在不同场景下管理GPG密钥。

## 功能特性

- ✅ **导出GPG密钥**：支持导出公钥、私钥和撤销证书
- ✅ **导入GPG密钥**：批量导入指定目录下的所有.asc密钥文件
- ✅ **交互式菜单**：提供用户友好的交互式操作界面
- ✅ **自动检测**：检查GPG安装状态
- ✅ **批量操作**：支持批量导入密钥文件

## 系统要求

- Windows操作系统
- PowerShell 5.0或更高版本
- GnuPG (GPG) 已安装并配置到系统PATH

## 安装指南

1. 确保已安装GnuPG：
   ```powershell
   gpg --version
   ```

2. 如果未安装，可以通过以下方式安装：
   - 使用Scoop: `scoop install gpg`
   - 使用Winget（推荐）: `winget install GnuPG.GnuPG`
   - 官网下载：https://gnupg.org/download/

3. 生成密钥：
   ```powershell
   gpg --full-generate-key
   ```

## 使用方法

### 1. 命令行参数模式

#### 导出密钥
```powershell
.\GPGKeyManager.ps1 -Action export -KeyID <密钥ID> -Path <导出路径>
```

**示例：**
```powershell
.\GPGKeyManager.ps1 -Action export -KeyID ABC12345 -Path C:\MyKeys\
```

#### 导入密钥
```powershell
.\GPGKeyManager.ps1 -Action import -Path <导入路径>
```

**示例：**
```powershell
.\GPGKeyManager.ps1 -Action import -Path C:\MyKeys\
```

### 2. 交互式菜单模式

直接运行脚本（不带参数）：
```powershell
.\GPGKeyManager.ps1
```

脚本将显示交互式菜单，您可以：
1. 选择导出密钥
2. 选择导入密钥
3. 退出程序

## 参数说明

| 参数 | 类型 | 必需 | 默认值 | 描述 |
|------|------|------|--------|------|
| `-Action` | String | 否 | - | 操作类型：`export`（导出）或`import`（导入） |
| `-KeyID` | String | 导出时必需 | - | 要导出的GPG密钥ID |
| `-Path` | String | 否 | `.\GPG_Keys\` | 密钥存储路径 |

## 文件结构

执行导出操作后，会在指定目录下生成以下文件：

```
指定目录/
├── public_key_<密钥ID>.asc      # 公钥文件
├── private_key_<密钥ID>.asc     # 私钥文件
└── revocation_cert_<密钥ID>.asc  # 撤销证书（如存在）
```

## 严格安全建议

如果你需要把密钥通过公开系统传输，建议通过更严格的再次加密之后再传输。
以避免密钥进一步泄露的风险。我个人使用自己的小工具 `rpawomaster` 来进行再次加密
（使用方法见[网页](https://github.com/sidneylyzhang/rpawomaster)），
你也可以使用其他加密方案，不过就不要使用`gpg`来再次加密了，毕竟`gpg`加密/解密是依赖本地密钥的。

## 密钥ID获取

要获取您的GPG密钥ID，可以运行：
```powershell
gpg --list-keys --keyid-format LONG
```

输出示例：
```
pub   rsa4096/ABC12345DEF67890 2025-08-25 [SC] [expires: 2026-08-25]
      ZZZZXXX...........................
uid           [ultimate] Your Name <your.email@example.com>
sub   rsa4096/XYZ1234567890 2023-01-01 [E] [expires: 2026-08-25]
```

其中`ABC12345DEF67890`就是您的密钥ID。

## 使用示例

### 完整工作流示例

1. **导出密钥**：
   ```powershell
   .\GPGKeyManager.ps1 -Action export -KeyID ABC12345 -Path D:\Backup\GPG\
   ```

2. **导入密钥到新系统**：
   ```powershell
   .\GPGKeyManager.ps1 -Action import -Path D:\Backup\GPG\
   ```

3. **使用交互式菜单**：
   ```powershell
   .\GPGKeyManager.ps1
   ```

## 常见问题

### Q: 运行脚本时提示"未找到GPG安装"
A: 请确保GnuPG已正确安装，并且`gpg`命令已添加到系统环境变量PATH中。

### Q: 导出私钥时失败
A: 导出私钥需要管理员权限，请确保以管理员身份运行PowerShell。

### Q: 导入密钥后如何验证？
A: 导入完成后，脚本会自动显示当前系统中的GPG密钥列表，您也可以手动运行：
```powershell
gpg --list-keys
```

### Q: 支持哪些密钥格式？
A: 目前支持标准的ASCII-armored格式（.asc文件）。

## 安全注意事项

- **保护私钥**：导出的私钥文件包含敏感信息，请妥善保管
- **撤销证书**：撤销证书一旦泄露，他人可以撤销您的密钥
- **文件权限**：确保密钥文件存储在安全的位置，设置适当的文件权限
- **传输安全**：通过网络传输密钥文件时，请使用加密通道

## 故障排除

### 错误代码说明

| 错误代码 | 描述 | 解决方案 |
|----------|------|----------|
| 1 | GPG未安装 | 安装GnuPG并配置PATH |
| 2 | 密钥ID无效 | 检查密钥ID是否正确 |
| 3 | 路径不存在 | 创建目录或指定有效路径 |
| 4 | 权限不足 | 以管理员身份运行PowerShell |

### 调试模式

如需调试，可以在PowerShell中启用详细输出：
```powershell
$VerbosePreference = "Continue"
.\GPGKeyManager.ps1
```

## 更新日志

### v1.0.0
- 初始版本
- 支持密钥导出功能
- 支持密钥导入功能
- 提供交互式菜单

## 许可证

本项目采用MIT许可证，详见项目根目录的LICENSE文件。

## 贡献

欢迎提交Issue和Pull Request来改进这个脚本。

## 联系方式

如有问题或建议，请在项目GitHub仓库提交Issue。