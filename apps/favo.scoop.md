# scoop 的偏爱配置

## （1）安装时的配置

C盘任何时候都需要被拯救，即使只有一个硬盘分区，也需要拯救一下你的`AppData`文件夹……
所以提供本身安装位置与全局软件安装位置，绝对是最推荐的。

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

$env:SCOOP='D:\Applications\Scoop'
$env:SCOOP_GLOBAL='F:\GlobalScoopApps'
[Environment]::SetEnvironmentVariable('SCOOP_GLOBAL', $env:SCOOP_GLOBAL, 'Machine')

irm get.scoop.sh | iex
```

## （2）使用时的配置

因为Scoop大量使用了Github的资源，所以经常性的连接不佳，所以啊，proxy还是很必要的。

```powershell
scoop config proxy 127.0.0.1:2334
```

取消代理：

```powershell
scoop config rm proxy
```

## （3）常用软件

1. ollama: 配合私有部署的[lobechat](https://lobehub.com)实现方便而且安全的AI聊天体验。
2. pipx: python CLI工具的安装管理器。
3. rye: python项目管理，虽然还有不完美，但速度就是一切！
4. python: 紧跟最新版本的python。
5. git: 必要的工具。
6. starship: 优化终端显示的工具。
7. nu: 好用炸裂的shell程序，和powershell有一拼。
8. gh: github的CLI管理器，好用。
9. 7zip: 压缩解压缩的好物。
10. typst: 很不错的排版软件，比latex轻量，也便于日常工作使用。
11. pandoc: 格式转换的工具。
12. cmake & msys2: 编译工具。
13. aria2: 下载工具，也超好用。
14. sumatrapdf: 多种格式的阅读器，体积小、功能简单好用。