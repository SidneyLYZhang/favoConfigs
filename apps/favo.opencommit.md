# OpenCommit

安装：

1. 需要安装`nodejs` 和 `npm`。
2. 使用 `npm config set registry https://registry.npmmirror.com` 配置镜像。
3. 使用 `npm install -g opencommit` 安装。

配置：

```shell
OCO_LANGUAGE=zh_CN
OCO_MODEL=gpt-4o-mini
OCO_API_URL=https://api.lyz.one/v1
OCO_API_KEY=<key>
OCO_EMOJI=true
OCO_ONE_LINE_COMMIT=true
```

使用 `oco config set <name>=<value>` 的格式设定。也可以直接更改源文件。


解决 `DeprecationWarning: The punycode module is deprecated.` 问题：

1. 增加 `npm install punycode --save` 到对应项目。
2. 不一定能解决的问题……可能最好的方式是限定node版本。