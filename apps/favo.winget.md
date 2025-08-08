# WinGet



windows一般已经自带。无需安装。直接使用命令行进行使用。

官方通用的教程或者说明： [WinGet](https://learn.microsoft.com/en-us/windows/package-manager/) 。



## 配置

使用 `winget settings` 打开配置文件。

我的常用配置：

```json
{
    "$schema": "https://aka.ms/winget-settings.schema.json",
    "visual": {
        "enableSixels": true,
        "progressBar": "rainbow"
    },
    "experimentalFeatures": {
        "experimentalARG": true,
        "experimentalCMD": true
    },
    "downloadBehavior": {
        "defaultDownloadDirectory": "D:/Downloads/WINGET"
    },
    "installBehavior": {
        "defaultInstallRoot": "D:/Configs/WinGetApps/Default",
        "portablePackageUserRoot": "D:/Configs/WinGetApps/Portable/User",
        "portablePackageMachineRoot": "D:/Configs/WinGetApps/Portable/Machine"
    }
```

## 使用

安装，可以先进行查找，找到id后再安装。

```bash
$ winget search jq
名称    ID            版本   匹配        源
-----------------------------------------------
jq      jqlang.jq     1.8.1              winget
TheDesk Cutls.TheDesk 24.2.1 Tag: jquery winget

$ winget install jqlang.jq
```



更新，直接使用 `winget update --all` 。

但是通常我不会使用winget一次性更新所有软件。我会只更新部分，所以需要检查哪些需要更新：

```bash
$ winget list --upgrade-available
名称                                                        ID                           版本                   可用                    源
----------------------------------------------------------------------------------------------------------------------------------------------
PostgreSQL 17                                               PostgreSQL.PostgreSQL.17     17.4-1                 17.5-3                  winget
Obsidian                                                    Obsidian.Obsidian            1.8.7                  1.8.10                  winget
Microsoft Visual Studio Code                                Microsoft.VisualStudioCode   1.102.3                1.103.0                 winget
钉钉                                                        Alibaba.DingTalk             7.5.11-Release.3179106 7.8.5-Release.250710001 winget
Microsoft Edge                                              Microsoft.Edge               138.0.3351.121         139.0.3405.86           winget
微信                                                        Tencent.WeChat               3.9.12.17              3.9.12.55               winget
Microsoft Visual C++ 2015-2022 Redistributable (x64) - 14.… Microsoft.VCRedist.2015+.x64 14.44.35208.0          14.44.35211.0           winget
Microsoft Visual C++ 2015-2022 Redistributable (x86) - 14.… Microsoft.VCRedist.2015+.x86 14.42.34438.0          14.44.35211.0           winget
飞书                                                        ByteDance.Feishu             7.46.6                 7.49.7                  winget
Python 3.11.7 (64-bit)                                      Python.Python.3.11           3.11.7                 3.11.9                  winget
Microsoft Teams                                             Microsoft.Teams              1.0.0.0                25198.1109.3837.4725    winget
11 升级可用。
```

然后选择需要安装的软件id进行安装，例如： `winget upgrade -id Ollama.Ollama` 。








