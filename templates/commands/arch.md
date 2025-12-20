---
description: Analyze the project architecture and system context, updating the project memory.
description-cn: 分析项目架构和系统上下文，并更新项目记忆（Memory）。
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

[CN]
## 用户输入

```text
$ARGUMENTS
```

如果有用户输入，在继续之前**必须**先考虑用户输入（如果不为空）。
[/CN]

## Outline

You are updating the project architecture documentation at `memory/project.md`. Your goal is to provide a comprehensive view of the system's structure, context, and technology stack.

Follow this execution flow:

1. **Scan and Analyze**:
   - Explore the codebase to identify the primary programming languages, frameworks, and key libraries.
   - Map the directory structure to understand the high-level component organization.
   - Identify external dependencies (APIs, databases, third-party services).
   - Trace key data flows through the system.

2. **Collect/Derive Architecture Details**:
   - If user input provides specific architectural constraints or context, incorporate it.
   - Infer the `[PROJECT_NAME]` and `[SYSTEM_DESCRIPTION]` from README files and project metadata.
   - Populate the `System Context` section with a description or a Mermaid diagram of external integrations.
   - Detail the `Components` and their responsibilities.
   - Document the `Technology Stack` used in the project.

3. **Draft the Updated Documentation**:
   - Use the template at `memory/project.md` as your guide.
   - Replace every placeholder `[ALL_CAPS_IDENTIFIER]` with concrete, factual information.
   - Ensure the `LAST_UPDATED_DATE` is set to today (YYYY-MM-DD).

4. **Consistency Check**:
   - Verify that the architecture description aligns with the project's `README.md` and `constitution.md`.
   - Ensure all key technical decisions reflected in the code are captured.

5. **Final Output**:
   - Write the completed architecture documentation back to `memory/project.md` (overwrite).
   - Provide a summary of the key findings and any major changes made to the documentation.

[CN]
## 流程大纲

你正在更新位于 `memory/project.md` 的项目架构文档。你的目标是提供系统结构、上下文和技术栈的全面视图。

请遵循以下执行流程：

1. **扫描与分析**：
   - 探索代码库以识别主要的编程语言、框架和核心库。
   - 映射目录结构以了解高层组件的组织方式。
   - 识别外部依赖项（API、数据库、第三方服务）。
   - 追踪系统中的核心数据流。

2. **收集/推导架构细节**：
   - 如果用户输入提供了特定的架构约束或背景，请将其整合进去。
   - 从 README 文件和项目元数据中推导 `[PROJECT_NAME]` 和 `[SYSTEM_DESCRIPTION]`。
   - 用外部集成的描述或 Mermaid 图表填充 `System Context` 部分。
   - 详细说明 `Components` 及其职责。
   - 记录项目中使用的 `Technology Stack`（技术栈）。

3. **起草更新后的文档**：
   - 使用 `memory/project.md` 中的模板作为指导。
   - 将每个占位符 `[ALL_CAPS_IDENTIFIER]` 替换为具体的、事实性的信息。
   - 确保 `LAST_UPDATED_DATE` 设置为今天 (YYYY-MM-DD)。

4. **一致性检查**：
   - 验证架构描述是否与项目的 `README.md` 和 `constitution.md` 保持一致。
   - 确保代码中所体现的关键技术决策都已被记录。

5. **最终输出**：
   - 将完整的架构文档写回 `memory/project.md`（覆盖）。
   - 提供关键发现的摘要以及对文档所做的主要更改。
[/CN]

## Guidelines

- Focus on accuracy and clarity.
- Use Mermaid diagrams where helpful to visualize complex relationships.
- Keep the description technology-focused but accessible.
- If certain details are unknown, mark them as `[UNKNOWN: Description of what is missing]`.

[CN]
## 指南

- 专注于准确性和清晰度。
- 在有助于可视化复杂关系的地方使用 Mermaid 图表。
- 保持描述侧重于技术，但要易于理解。
- 如果某些细节未知，请将其标记为 `[UNKNOWN: 缺失内容的描述]`。
[/CN]

