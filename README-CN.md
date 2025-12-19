<div align="center">
    <img src="./media/logo_large.webp" alt="Spec Kit Logo" width="200" height="200"/>
    <h1>🌱 Spec Kit</h1>
    <h3><em>更快地构建高质量软件。</em></h3>
</div>

<p align="center">
    <strong>一个开源工具包，让你专注于产品场景和可预测的结果，而不是从头开始编写每一个片段。</strong>
</p>

<p align="center">
    <a href="./README.md">English</a> | <a href="./README-CN.md">简体中文</a>
</p>

<p align="center">
    <a href="https://github.com/zixun-github/spec-kit/actions/workflows/release.yml"><img src="https://github.com/zixun-github/spec-kit/actions/workflows/release.yml/badge.svg" alt="Release"/></a>
    <a href="https://github.com/zixun-github/spec-kit/stargazers"><img src="https://img.shields.io/github/stars/github/spec-kit?style=social" alt="GitHub stars"/></a>
    <a href="https://github.com/zixun-github/spec-kit/blob/main/LICENSE"><img src="https://img.shields.io/github/license/github/spec-kit" alt="License"/></a>
    <a href="https://github.github.io/spec-kit/"><img src="https://img.shields.io/badge/docs-GitHub_Pages-blue" alt="Documentation"/></a>
</p>

---

## 目录

- [🤔 什么是规范驱动开发？](#-什么是规范驱动开发)
- [⚡ 快速开始](#-快速开始)
- [📽️ 视频概览](#️-视频概览)
- [🤖 支持的 AI 代理](#-支持的-ai-代理)
- [🔧 Specify CLI 参考](#-specify-cli-参考)
- [📚 核心理念](#-核心理念)
- [🌟 开发阶段](#-开发阶段)
- [🎯 实验目标](#-实验目标)
- [🔧 前置条件](#-前置条件)
- [📖 了解更多](#-了解更多)
- [📋 详细流程](#-详细流程)
- [🔍 故障排除](#-故障排除)
- [👥 维护者](#-维护者)
- [💬 支持](#-支持)
- [🙏 致谢](#-致谢)
- [📄 许可证](#-许可证)

## 🤔 什么是规范驱动开发？

规范驱动开发**颠覆了**传统软件开发的模式。几十年来，代码一直是王道——规范只是我们构建和丢弃的脚手架，一旦"真正的工作"（编码）开始。规范驱动开发改变了这一点：**规范变得可执行**，直接生成可工作的实现，而不仅仅是指导它们。

## ⚡ 快速开始

### 1. 安装 Specify CLI

选择你喜欢的安装方式：

#### 选项 1：持久化安装（推荐）

一次安装，随处使用：

```bash
uv tool install specify-cli --from git+https://github.com/zixun-github/spec-kit.git
```

然后直接使用工具：

```bash
# 创建新项目
specify init <PROJECT_NAME>

# 或在现有项目中初始化
specify init . --ai claude
# 或者
specify init --here --ai claude

# 检查已安装的工具
specify check
```

要升级 Specify，请查看[升级指南](./docs/upgrade.md)获取详细说明。快速升级：

```bash
uv tool install specify-cli --force --from git+https://github.com/zixun-github/spec-kit.git
```

#### 选项 2：一次性使用

不安装直接运行：

```bash
uvx --from git+https://github.com/zixun-github/spec-kit.git specify init <PROJECT_NAME>
```

**持久化安装的好处：**

- 工具保持安装并在 PATH 中可用
- 无需创建 shell 别名
- 使用 `uv tool list`、`uv tool upgrade`、`uv tool uninstall` 更好地管理工具
- 更干净的 shell 配置

### 2. 建立项目原则

在项目目录中启动你的 AI 助手。助手中会提供 `/speckit.*` 命令。

使用 **`/speckit.constitution`** 命令创建项目的治理原则和开发指南，这将指导所有后续开发。

```bash
/speckit.constitution 创建专注于代码质量、测试标准、用户体验一致性和性能要求的原则
```

### 3. 定义功能

一旦你有了原则，使用 **`/speckit.specify`** 命令创建功能规范：

```bash
/speckit.specify 我想要一个照片相册功能，用户可以创建、编辑和共享相册。每个相册最多可以包含 100 张照片。
```

### 4. 计划实施

使用 **`/speckit.plan`** 命令生成技术实施计划：

```bash
/speckit.plan 我正在使用 React + TypeScript 构建
```

### 5. 执行任务

使用 **`/speckit.tasks`** 命令生成可执行的任务列表，然后使用 **`/speckit.implement`** 命令执行它们：

```bash
/speckit.tasks
/speckit.implement
```

## 📽️ 视频概览

🎥 **观看此快速 5 分钟演示**，了解如何使用 Spec-Driven Development 和 Claude Code 构建全栈功能：

[![Spec-Driven Development 演示](./media/spec-kit-video-header.jpg)](https://www.youtube.com/watch?v=YOUR_VIDEO_ID)

## 🤖 支持的 AI 代理

| 代理                                                                                  | 支持 | 备注                                                                                                                              |
| ------------------------------------------------------------------------------------ | ---- | --------------------------------------------------------------------------------------------------------------------------------- |
| [Qoder CLI](https://qoder.com/cli)                                                  | ✅   |                                                                                                                                   |
| [Amazon Q Developer CLI](https://aws.amazon.com/developer/learning/q-developer-cli/) | ⚠️   | Amazon Q Developer CLI [不支持](https://github.com/aws/amazon-q-developer-cli/issues/3064)自定义参数的斜杠命令。                   |
| [Amp](https://ampcode.com/)                                                          | ✅   |                                                                                                                                   |
| [Auggie CLI](https://docs.augmentcode.com/cli/overview)                             | ✅   |                                                                                                                                   |
| [Claude Code](https://www.anthropic.com/claude-code)                                | ✅   |                                                                                                                                   |
| [CodeBuddy CLI](https://www.codebuddy.ai/cli)                                       | ✅   |                                                                                                                                   |
| [Codex CLI](https://github.com/openai/codex)                                        | ✅   |                                                                                                                                   |
| [Cursor](https://cursor.sh/)                                                        | ✅   |                                                                                                                                   |
| [Gemini CLI](https://github.com/google-gemini/gemini-cli)                           | ✅   |                                                                                                                                   |
| [GitHub Copilot](https://code.visualstudio.com/)                                    | ✅   |                                                                                                                                   |
| [IBM Bob](https://www.ibm.com/products/bob)                                         | ✅   | 基于 IDE 的代理，支持斜杠命令                                                                                                      |
| [Jules](https://jules.google.com/)                                                  | ✅   |                                                                                                                                   |
| [Kilo Code](https://github.com/Kilo-Org/kilocode)                                   | ✅   |                                                                                                                                   |
| [opencode](https://opencode.ai/)                                                    | ✅   |                                                                                                                                   |
| [Qwen Code](https://github.com/QwenLM/qwen-code)                                    | ✅   |                                                                                                                                   |
| [Roo Code](https://roocode.com/)                                                    | ✅   |                                                                                                                                   |
| [SHAI (OVHcloud)](https://github.com/ovh/shai)                                      | ✅   |                                                                                                                                   |
| [Windsurf](https://windsurf.com/)                                                   | ✅   |                                                                                                                                   |

## 🔧 Specify CLI 参考

`specify` 命令支持以下选项：

### 命令

| 命令    | 描述                                                                                                                       |
| ------- | -------------------------------------------------------------------------------------------------------------------------- |
| `init`  | 从最新模板初始化新的 Specify 项目                                                                                          |
| `check` | 检查已安装的工具（`git`、`claude`、`gemini`、`code`/`code-insiders`、`cursor-agent`、`windsurf`、`qwen`、`opencode`、`codex`、`shai`、`qoder`） |

### `specify init` 参数和选项

| 参数/选项              | 类型   | 描述                                                                                                                     |
| ---------------------- | ------ | ------------------------------------------------------------------------------------------------------------------------ |
| `<project-name>`       | 参数   | 新项目目录名称（如果使用 `--here`，则为可选，或使用 `.` 表示当前目录）                                                   |
| `--ai`                 | 选项   | 要使用的 AI 助手：`claude`、`gemini`、`copilot`、`cursor-agent`、`qwen`、`opencode`、`codex`、`windsurf`、`kilocode`、`auggie`、`roo`、`codebuddy`、`amp`、`shai`、`q`、`bob` 或 `qoder` |
| `--script`             | 选项   | 要使用的脚本变体：`sh`（bash/zsh）或 `ps`（PowerShell）                                                                  |
| `--lang`               | 选项   | 模板语言：`en`（英文）或 `cn`（简体中文）。如果未指定，将提示你选择                                                       |
| `--ignore-agent-tools` | 标志   | 跳过 AI 代理工具（如 Claude Code）的检查                                                                                 |
| `--no-git`             | 标志   | 跳过 git 仓库初始化                                                                                                      |
| `--here`               | 标志   | 在当前目录中初始化项目，而不是创建新目录                                                                                 |
| `--force`              | 标志   | 在当前目录初始化时强制合并/覆盖（跳过确认）                                                                              |
| `--skip-tls`           | 标志   | 跳过 SSL/TLS 验证（不推荐）                                                                                              |
| `--debug`              | 标志   | 启用详细的调试输出以进行故障排除                                                                                         |
| `--github-token`       | 选项   | 用于 API 请求的 GitHub 令牌（或设置 GH_TOKEN/GITHUB_TOKEN 环境变量）                                                     |

### 示例

```bash
# 使用 Claude 支持初始化
specify init my-project --ai claude

# 使用 Gemini 支持初始化
specify init my-project --ai gemini

# 使用 GitHub Copilot 支持初始化
specify init my-project --ai copilot

# 使用 Cursor 支持初始化
specify init my-project --ai cursor-agent

# 使用 Qoder 支持初始化
specify init my-project --ai qoder

# 使用 Windsurf 支持初始化
specify init my-project --ai windsurf

# 使用 Amp 支持初始化
specify init my-project --ai amp

# 使用 SHAI 支持初始化
specify init my-project --ai shai

# 使用 IBM Bob 支持初始化
specify init my-project --ai bob

# 使用 PowerShell 脚本初始化（Windows/跨平台）
specify init my-project --ai copilot --script ps

# 使用简体中文模板初始化
specify init my-project --ai claude --lang cn

# 使用英文模板初始化（默认值，如果未指定）
specify init my-project --ai claude --lang en

# 在当前目录中初始化
specify init . --ai copilot
# 或使用 --here 标志
specify init --here --ai copilot

# 强制合并到当前（非空）目录而不确认
specify init . --force --ai copilot
# 或
specify init --here --force --ai copilot

# 跳过 git 初始化
specify init my-project --ai gemini --no-git

# 启用调试输出以进行故障排除
specify init my-project --ai claude --debug

# 使用 GitHub 令牌进行 API 请求（对企业环境有帮助）
specify init my-project --ai claude --github-token ghp_your_token_here

# 检查系统要求
specify check
```

### 可用的斜杠命令

运行 `specify init` 后，你的 AI 编码代理将可以访问以下斜杠命令进行结构化开发：

#### 核心命令

规范驱动开发工作流的基本命令：

| 命令                    | 描述                                           |
| ----------------------- | ---------------------------------------------- |
| `/speckit.constitution` | 创建或更新项目治理原则和开发指南               |
| `/speckit.specify`      | 定义你想要构建的内容（需求和用户故事）         |
| `/speckit.plan`         | 使用你选择的技术栈创建技术实施计划             |
| `/speckit.tasks`        | 生成可执行的任务列表以进行实施                 |
| `/speckit.implement`    | 执行所有任务以根据计划构建功能                 |

#### 可选命令

用于增强质量和验证的附加命令：

| 命令                 | 描述                                                                                                   |
| -------------------- | ------------------------------------------------------------------------------------------------------ |
| `/speckit.clarify`   | 澄清未充分指定的区域（建议在 `/speckit.plan` 之前；以前称为 `/quizme`）                                |
| `/speckit.analyze`   | 跨工件一致性和覆盖率分析（在 `/speckit.tasks` 之后、`/speckit.implement` 之前运行）                   |
| `/speckit.checklist` | 生成自定义质量检查清单，验证需求的完整性、清晰度和一致性（类似于"英语的单元测试"）                     |

### 环境变量

| 变量              | 描述                                                                                                                                                                                                       |
| ----------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `SPECIFY_FEATURE` | 为非 Git 仓库覆盖功能检测。设置为功能目录名称（例如 `001-photo-albums`）以在不使用 Git 分支时处理特定功能。<br/>**必须在使用 `/speckit.plan` 或后续命令之前在你正在使用的代理上下文中设置。** |

## 📚 核心理念

规范驱动开发是一个结构化的过程，强调：

- **意图驱动开发**，规范在"如何做"之前定义"做什么"
- **使用护栏和组织原则创建丰富的规范**
- **多步骤细化**，而不是从提示一次性生成代码
- **重度依赖**高级 AI 模型能力进行规范解释

## 🌟 开发阶段

| 阶段                               | 重点             | 关键活动                                                                                                            |
| ---------------------------------- | ---------------- | ------------------------------------------------------------------------------------------------------------------- |
| **0 到 1 开发**（"绿地"）          | 从头开始生成     | <ul><li>从高级需求开始</li><li>生成规范</li><li>计划实施步骤</li><li>构建生产就绪的应用程序</li></ul>               |
| **创意探索**                       | 并行实施         | <ul><li>探索不同的解决方案</li><li>支持多种技术栈和架构</li><li>实验 UX 模式</li></ul>                              |
| **迭代增强**（"棕地"）             | 棕地现代化       | <ul><li>迭代添加功能</li><li>现代化遗留系统</li><li>调整流程</li></ul>                                              |

## 🎯 实验目标

我们的研究和实验专注于：

### 技术独立性

- 使任何技术栈都能轻松使用 Spec-Driven Development
- 尽量减少特定于框架的假设
- 支持多种实施方法

### 质量护栏

- 预防常见错误
- 提供最佳实践指导
- 持续验证
- 确保项目遵守既定原则

### 可测试性优先

- 强调从第一天开始的可测试性
- 将测试集成到开发工作流中
- 尽早识别和解决测试挑战

### 规范即真相源

- 将规范作为主要文档
- 让代码反映规范
- 跟踪规范变更随时间的演变

## 🔧 前置条件

在使用 Spec Kit 之前，请确保你有以下工具：

### 必需的

- **Git**: 用于版本控制（`git --version`）
- **AI 编码助手**: 你选择的 AI 代理（见下文）

### AI 代理选项

根据你的偏好选择以下之一：

- **Claude Code**: [安装说明](https://www.anthropic.com/claude-code)
- **Gemini CLI**: [安装说明](https://github.com/google-gemini/gemini-cli)
- **GitHub Copilot**: [安装说明](https://code.visualstudio.com/)
- **Cursor**: [安装说明](https://cursor.sh/)
- **Qoder CLI**: [安装说明](https://qoder.com/cli)
- **Windsurf**: [安装说明](https://windsurf.com/)
- **其他支持的代理**: 见上面的[支持的 AI 代理](#-支持的-ai-代理)表

### 脚本执行环境

选择以下之一：

- **Bash/Zsh**: macOS/Linux（默认）
- **PowerShell 7+**: Windows/跨平台（使用 `--script ps`）

## 📖 了解更多

- **[安装指南](./docs/installation.md)**: 详细的安装说明
- **[快速入门](./docs/quickstart.md)**: 分步教程
- **[本地开发](./docs/local-development.md)**: 贡献者指南
- **[升级指南](./docs/upgrade.md)**: 如何升级 Specify CLI

## 📋 详细流程

### 1. Constitution（章程）

**目的**: 建立项目的治理原则和开发指南。

**何时使用**: 在项目开始时或当你想要重新定义项目原则时。

**示例**:
```bash
/speckit.constitution 创建专注于代码质量、测试标准、用户体验一致性和性能要求的原则
```

### 2. Specify（规范）

**目的**: 定义你想要构建的内容，包括需求和用户故事。

**何时使用**: 当你有一个新功能想法或想要记录现有功能时。

**示例**:
```bash
/speckit.specify 我想要一个照片相册功能，用户可以创建、编辑和共享相册
```

### 3. Clarify（澄清）

**目的**: 识别和解决规范中未充分指定的区域。

**何时使用**: 在创建技术计划之前，确保所有需求都清晰。

**示例**:
```bash
/speckit.clarify
```

### 4. Plan（计划）

**目的**: 基于规范创建技术实施计划。

**何时使用**: 在开始实施之前，需要技术设计。

**示例**:
```bash
/speckit.plan 我正在使用 React + TypeScript + Tailwind 构建
```

### 5. Tasks（任务）

**目的**: 从计划生成可执行的任务列表。

**何时使用**: 当你准备开始实施时。

**示例**:
```bash
/speckit.tasks
```

### 6. Analyze（分析）

**目的**: 分析任务和设计工件的一致性和覆盖率。

**何时使用**: 在开始实施之前，验证任务完整性。

**示例**:
```bash
/speckit.analyze
```

### 7. Implement（实施）

**目的**: 执行任务列表以构建功能。

**何时使用**: 当你准备编写代码时。

**示例**:
```bash
/speckit.implement
```

### 8. Checklist（检查清单）

**目的**: 生成自定义质量检查清单以验证需求。

**何时使用**: 当你想要确保需求质量时。

**示例**:
```bash
/speckit.checklist 为用户认证功能创建检查清单
```

## 🔍 故障排除

### 常见问题

#### 1. AI 代理找不到斜杠命令

**症状**: 当你尝试使用 `/speckit.*` 命令时，AI 代理表示不知道该命令。

**解决方案**:
- 确保你在正确的项目目录中
- 验证 AI 代理已正确配置
- 重新启动 AI 代理
- 检查命令文件是否存在于正确的目录中（例如 `.claude/commands/`）

#### 2. 权限被拒绝错误

**症状**: 运行脚本时出现"权限被拒绝"错误。

**解决方案**:
```bash
# 对于 Bash/Zsh
chmod +x .specify/scripts/bash/*.sh

# 对于 PowerShell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

#### 3. Git 相关错误

**症状**: Git 命令失败或无法检测到功能分支。

**解决方案**:
- 确保已安装 Git：`git --version`
- 验证你在 Git 仓库中：`git status`
- 如果不使用 Git 分支，设置 `SPECIFY_FEATURE` 环境变量

#### 4. 网络相关错误

**症状**: 下载模板时出现网络错误。

**解决方案**:
- 检查你的互联网连接
- 如果在企业环境中，可能需要配置代理
- 使用 `--github-token` 选项进行 API 请求
- 使用 `--skip-tls` 跳过 SSL/TLS 验证（不推荐）

### 调试提示

启用调试输出以获取更多信息：

```bash
specify init my-project --ai claude --debug
```

这将显示详细的诊断输出以进行网络和提取故障。

## 👥 维护者

- [@github](https://github.com/github) - GitHub 团队

## 💬 支持

需要帮助？这里有几种获取支持的方式：

- **文档**: 查看 [GitHub Pages 文档](https://github.github.io/spec-kit/)
- **Issues**: 在我们的 [GitHub Issues](https://github.com/zixun-github/spec-kit/issues) 上报告错误或请求功能
- **讨论**: 在 [GitHub Discussions](https://github.com/zixun-github/spec-kit/discussions) 上加入社区对话

## 🙏 致谢

Spec Kit 建立在现代开发工具和 AI 技术的基础之上。感谢所有开源贡献者和 AI 研究人员使这个项目成为可能。

## 📄 许可证

本项目根据 [MIT 许可证](./LICENSE)获得许可。

