# SetTempEnv PowerShell 模块

一个用于管理 PowerShell 会话中临时环境变量的模块。所有操作仅影响当前会话，不会改变系统或用户环境变量。

## 功能特性

- ✅ **设置临时环境变量** - 在当前会话中临时设置环境变量
- 🔍 **查询环境变量** - 查看当前会话中的环境变量信息
- 🗑️ **移除环境变量** - 支持通配符匹配的批量移除
- 🧹 **清空环境变量** - 一键清空所有临时环境变量，智能排除系统变量
- 🛡️ **安全保护** - 支持 WhatIf 操作，防止误操作
- 📊 **详细信息** - 返回操作结果对象，包含时间戳和详细信息

## 安装

### 手动安装

1. 下载整个 `SetTempEnv` 文件夹
2. 将其复制到 PowerShell 模块目录之一：
   - 当前用户: `$HOME\Documents\PowerShell\Modules\`
   - 所有用户: `$PSHOME\Modules\`
3. 在 PowerShell 中运行：`Import-Module SetTempEnv`

### 自动安装

```powershell
# 克隆仓库
git clone https://github.com/yourusername/SetTempEnv.git

# 复制到模块目录
Copy-Item -Path ".\SetTempEnv" -Destination "$HOME\Documents\PowerShell\Modules\" -Recurse -Force

# 导入模块
Import-Module SetTempEnv
```

## 使用示例

### 设置临时环境变量

```powershell
# 基本用法
Set-TempEnv -Name "MY_VAR" -Value "test_value"

# 使用位置参数
Set-TempEnv "API_KEY" "secret123"

# 添加到 PATH（临时）
Set-TempEnv "PATH" "$env:PATH;C:\MyTools"

# 使用 WhatIf 预览操作
Set-TempEnv -Name "TEST" -Value "value" -WhatIf
```

### 查询环境变量

```powershell
# 查看所有环境变量
Get-TempEnv

# 按名称模式查询
Get-TempEnv -Name "MY_*"

# 按值模式查询
Get-TempEnv -ValuePattern "*test*"

# 组合查询
Get-TempEnv -Name "API_*" -ValuePattern "*secret*"
```

### 移除环境变量

```powershell
# 移除单个变量
Remove-TempEnv -Name "MY_VAR"

# 使用通配符批量移除
Remove-TempEnv -Name "TEMP_*"

# 使用 WhatIf 预览移除操作
Remove-TempEnv -Name "TEST_*" -WhatIf
```

### 清空环境变量

```powershell
# 清空所有临时环境变量（自动排除系统变量）
Clear-TempEnv

# 清空时排除特定变量
Clear-TempEnv -Exclude "MY_IMPORTANT_VAR", "API_KEY"

# 包含系统变量（谨慎使用）
Clear-TempEnv -IncludeSystem -WhatIf
```

## 高级用法

### 批量操作

```powershell
# 批量设置环境变量
@{
    "API_URL" = "https://api.example.com"
    "API_KEY" = "secret123"
    "DEBUG_MODE" = "true"
}.GetEnumerator() | ForEach-Object {
    Set-TempEnv -Name $_.Key -Value $_.Value
}

# 批量移除测试变量
Remove-TempEnv -Name "TEST_*"
```

### 脚本中使用

```powershell
# 在脚本开头设置临时变量
param(
    [string]$Environment = "development"
)

# 设置环境相关变量
Set-TempEnv "ENVIRONMENT" $Environment
Set-TempEnv "CONFIG_FILE" "config.$Environment.json"

# 脚本逻辑...

# 脚本结束前清理
Clear-TempEnv -Exclude "ENVIRONMENT"  # 保留某些变量
```

### 调试和日志

```powershell
# 启用详细输出
$VerbosePreference = "Continue"

# 查看详细操作信息
Set-TempEnv -Name "DEBUG_VAR" -Value "test" -Verbose
Get-TempEnv -Verbose
```

## 函数详细说明

### Set-TempEnv

设置临时环境变量。

**参数:**
- `-Name` (必需): 环境变量名称
- `-Value` (必需): 环境变量值
- `-WhatIf`: 预览操作而不执行

**返回:** 包含操作信息的对象

### Get-TempEnv

查询临时环境变量。

**参数:**
- `-Name`: 名称模式（默认：*）
- `-ValuePattern`: 值匹配模式（默认：*）

**返回:** 环境变量信息对象数组

### Remove-TempEnv

移除临时环境变量。

**参数:**
- `-Name` (必需): 环境变量名称，支持通配符
- `-WhatIf`: 预览操作而不执行

**返回:** 被移除的环境变量信息数组

### Clear-TempEnv

清空所有临时环境变量。

**参数:**
- `-Exclude`: 要排除的变量名称数组
- `-IncludeSystem`: 是否包含系统变量
- `-WhatIf`: 预览操作而不执行

**返回:** 被清空的变量信息数组

## 安全特性

- **WhatIf 支持**: 所有修改操作都支持 `-WhatIf` 参数
- **系统变量保护**: `Clear-TempEnv` 默认排除常见系统变量
- **参数验证**: 自动验证环境变量名称的合法性
- **错误处理**: 完善的错误处理和用户友好的错误消息

## 注意事项

1. **临时性**: 所有操作仅影响当前 PowerShell 会话
2. **大小写**: Windows 环境变量不区分大小写
3. **系统变量**: 建议不要修改系统重要变量
4. **性能**: 大量操作时建议使用管道和批量处理

## 故障排除

### 常见问题

**Q: 模块无法导入**
```powershell
# 检查执行策略
Get-ExecutionPolicy

# 临时设置执行策略
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Q: 环境变量设置后不生效**
```powershell
# 确认变量已设置
Get-TempEnv -Name "YOUR_VAR"

# 检查变量名称是否合法
# 只能包含字母、数字和下划线，不能以数字开头
```

**Q: 无法移除某些变量**
```powershell
# 检查是否有权限问题
# 某些系统变量可能需要管理员权限

# 使用通配符时要小心
Remove-TempEnv -Name "TEMP_*" -WhatIf  # 先预览
```

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件