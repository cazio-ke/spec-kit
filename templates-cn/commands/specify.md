---
description: 根据自然语言功能描述创建或更新功能规范。
handoffs: 
  - label: 构建技术计划
    agent: speckit.plan
    prompt: 为该规范制定计划。我正在使用的技术栈是...
  - label: 澄清规范需求
    agent: speckit.clarify
    prompt: 澄清规范需求
    send: true
scripts:
  sh: scripts/bash/create-new-feature.sh --json "{ARGS}"
  ps: scripts/powershell/create-new-feature.ps1 -Json "{ARGS}"
---

## 用户输入 (User Input)

```text
$ARGUMENTS
```

如果用户输入不为空，你 **必须** 在继续之前参考该输入。

## 大纲 (Outline)

用户在触发消息中 `/speckit.specify` 之后输入的文本 **即为** 功能描述。假设即使 `{ARGS}` 在下方按字面形式出现，你也始终可以在对话中获取该描述。除非用户提供了空命令，否则不要要求用户重复描述。

基于该功能描述，执行以下操作：

1.  **为分支生成一个简练的短名称**（2-4 个单词）：
    - 分析功能描述并提取最有意义的关键词。
    - 创建一个 2-4 个单词的短名称，以捕捉功能的本质。
    - 尽可能使用“动词-名词”格式（例如："add-user-auth", "fix-payment-bug"）。
    - 保留技术术语和缩略词（OAuth2, API, JWT 等）。
    - 保持简洁，但在概览时足以理解功能内容。
    - 示例：
        - "I want to add user authentication"（我想添加用户认证） → "user-auth"
        - "Implement OAuth2 integration for the API"（为 API 实现 OAuth2 集成） → "oauth2-api-integration"
        - "Create a dashboard for analytics"（创建一个分析仪表板） → "analytics-dashboard"
        - "Fix payment processing timeout bug"（修复支付处理超时错误） → "fix-payment-timeout"

2.  **在创建新分支前检查现有分支**：

    a. 首先，获取所有远程分支以确保信息最新：

       ```bash
       git fetch --all --prune
       ```

    b. 查找该短名称在所有来源中的最大功能编号：
       - 远程分支：`git ls-remote --heads origin | grep -E 'refs/heads/[0-9]+-<short-name>$'`
       - 本地分支：`git branch | grep -E '^[* ]*[0-9]+-<short-name>$'`
       - Specs 目录：检查匹配 `specs/[0-9]+-<short-name>` 的目录

    c. 确定下一个可用编号：
       - 提取所有三个来源中的所有编号。
       - 找到最大编号 N。
       - 使用 N+1 作为新分支的编号。

    d. 使用计算出的编号和短名称运行脚本 `{SCRIPT}`：
       - 将 `--number N+1` 和 `--short-name "your-short-name"` 连同功能描述一起传递。
       - Bash 示例：`{SCRIPT} --json --number 5 --short-name "user-auth" "Add user authentication"`
       - PowerShell 示例：`{SCRIPT} -Json -Number 5 -ShortName "user-auth" "Add user authentication"`

    **重要提示**：
    - 检查所有三个来源（远程分支、本地分支、specs 目录）以找到最大编号。
    - 仅匹配具有精确短名称模式的分支/目录。
    - 如果