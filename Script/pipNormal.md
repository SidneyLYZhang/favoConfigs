# 有关 Python

这是一个减少记忆的选择……为了一些特殊情况下，可以更快速的完成初始化，而做的一些准备。

## 常用 Packages

想起来再加……暂时先记录这些。

通用处理：
- [pendulum](https://pendulum.eustace.io/) : 时间处理的好选择。【My Favorite】
- [simtoolsz](https://github.com/SidneyLYZhang/simtoolsz) : 个人常用的一些小工具小函数。
- [thefuzz](https://github.com/seatgeek/thefuzz) ： 字符串相似度计算库。
- [crawl4ai](https://github.com/unclecode/crawl4ai) ： 基于AI的爬虫程序库。

图片处理：
- [Pillow](https://pillow.readthedocs.io/en/stable/) : 标准的选择。
- [Puhu](https://github.com/bgunebakan/puhu) : 使用Rust构建的快速基础版本Pillow。

数据处理：
- [Pandas](https://pandas.pydata.org/) : 标准的选择。目前已经用的越来越少了。
- [Polars](https://pola.rs/) : 基于Rust的DataFrame库，速度快，内存占用低，单机数据处理必备。【My Favorite】
- [DuckDB](https://duckdb.org/) : 分析系统，高效的内嵌数据分析型数据库。
- [Numpy](https://numpy.org/) : 标准的选择。最初的数据处理库，很多后续Package的先决条件。

概率统计：
- [SciPy](https://scipy.org/) : 标准的选择。
- [StatsModels](https://www.statsmodels.org/stable/index.html) : 统计模型库，提供了统计分析和模型拟合的功能。

时间序列：_时序分析的方法变化太多，llm也可以作为时序分析的工具，具体问题具体分析，就是选择时序分析的基本准则。_
- [tsfresh](https://tsfresh.readthedocs.io/en/latest/index.html) ： 时序特征检测，减少人工特征提取工作量。
- [sktime](https://www.sktime.net/en/stable/index.html) ： 简单的时序分析库，教程很详细，功能还不错。
- [darts](https://unit8co.github.io/darts/README.html) ： 基于Pytorch的时序分析库，功能很全面。

数据分析：
- [Scikit-learn](https://scikit-learn.org/stable/) : 标准的选择。机器学习库，提供了各种机器学习算法和工具。
- [ibis](https://ibis-project.org/) : 快速的中间处理库，多类型后端支持和可视化支持。
- [sympy](https://www.sympy.org/) : 符号计算库，提供了符号计算和数学表达式的功能。

可视化：
- [matplotlib](https://matplotlib.org/) : 标准的选择。2D绘图库，提供了丰富的绘图功能。
- [seaborn](https://seaborn.pydata.org/) : 基于matplotlib的统计数据可视化库，提供了简单的接口来绘制 attractive 统计图表。
- [wordcloud](https://amueller.github.io/word_cloud/) : 词云库，提供了生成词云的功能。

LLM：
- [OpenAI](https://openai.com/) : 标准的选择。
- [HuggingFace](https://huggingface.co/) : 提供了许多预训练的模型和工具，支持多种任务。
- [pydantic-ai](https://ai.pydantic.dev/) ： 基于Pydantic的AI库，简洁方便的使用方案。

深度学习：
- [PyTorch](https://pytorch.org/) : 标准的选择。基于Python的科学计算库，提供了动态计算图和自动求导功能。
- [Gensim](https://github.com/piskvorky/gensim) ： 语言工具库。

其他：
- [spire-presentation](https://pypi.org/project/spire-presentation/) : 跨平台的PPT导出库。**非开源，非急误用**。[使用例](https://github.com/eiceblue/Spire.Presentation-for-Python/tree/main)。

## 安装管理

1. 核心使用 `uv` 进行基本环境管理。
2. 项目适时的使用 `rye` 和 `pixi` 进行管理。
3. Windows下的Python安装，适宜使用 `winget` 进行。

### `python` 安装

```powershell
winget install Python.Python.3.xxx
```

其中的`xxx`是版本号，最新的3.13就是`Python.Python.3.13` ，更新使用 `winget upgrade --id Python.Python.3.13` 进行也比较方便。
如果需要优化C盘空间，可以设定 `winget settings` 进行优化。当然，也可以使用软连接进行文件夹的重定向，将安装好的文件移到其他盘。

### `uv` 使用精要

为了便于管理，我使用 `scoop` 进行 `uv` 的全局安装。

```powershell
sudo scoop install uv -g
```

`uv` 更多用于简单脚本、工作项目的独立环境管理。这一类工作特点就是只需要考虑工作的持续性，不需要考虑那么多兼容性和完善的文本管理。
`uv init` 、 `uv venv` 、 `uv run` 、 `uv add` 、 `uv sync`、 `uv python`，这些命令日常就够用了。
当然，并非说明其他命令没用……只是我很多时候用的少。

### `rye` 使用精要

同样使用 `scoop` 进行 `rye` 的全局安装。

```powershell
sudo scoop install rye -g
```

`rye` 很多功能底层使用的就是 `uv`，我是用 `rye` 则主要进行纯Python项目的管理和构建，基本为了上传到pypi而使用。
`rye build` 进行项目的构建，`rye publish` 进行项目pypi的上传/发布。
虚拟环境管理上，和 `uv` 大同小异，毕竟其底层也是基于 `uv` 的。

### `pixi` 使用精要

`pixi` 现在越来越好用了，我也近期开始使用它进行一些项目管理，主要是那些混合项目，比如和R、Rust等进行混合的项目，
以及那些需要使用 `conda` 包的项目。

目前我用`scoop` 和 `winget` 都有安装的经历，但可能以后更多还是用 `scoop` 安装的概率更大：

```powershell
sudo scoop install pixi -g
```

`pixi` 最大的优势就是迁移性更好，可以完整准确定义项目运行和具体依赖的变化。使用上，
`pixi init`、`pixi add`、`pixi run`、`pixi task`、`pixi shell`，这些是我用的多的命令。