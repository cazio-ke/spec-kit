---
description: Create or update the project constitution from interactive or provided principle inputs, ensuring all dependent templates stay in sync.
description-cn: 根据交互式输入或提供的原则输入，创建或更新项目章程，确保所有依赖模板保持同步。
handoffs: 
  - label: Build Specification
    agent: speckit.specify
    prompt: Implement the feature specification based on the updated constitution. I want to build...

[CN]
  - label: 构建规范 (Build Specification)
    agent: speckit.specify
    prompt: 基于更新后的章程实施功能规范。我想构建……
[/CN]
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

[CN]
## 用户输入 (User Input)

```text
$ARGUMENTS
```

如果用户输入不为空，你 **必须** 在继续之前对其予以考虑。
[/CN]

## Outline

You are updating the project constitution at `/memory/constitution.md`. This file is a TEMPLATE containing placeholder tokens in square brackets (e.g. `[PROJECT_NAME]`, `[PRINCIPLE_1_NAME]`). Your job is to (a) collect/derive concrete values, (b) fill the template precisely, and (c) propagate any amendments across dependent artifacts.

Follow this execution flow:

1. Load the existing constitution template at `/memory/constitution.md`.
   - Identify every placeholder token of the form `[ALL_CAPS_IDENTIFIER]`.
   **IMPORTANT**: The user might require less or more principles than the ones used in the template. If a number is specified, respect that - follow the general template. You will update the doc accordingly.

2. Collect/derive values for placeholders:
   - If user input (conversation) supplies a value, use it.
   - Otherwise infer from existing repo context (README, docs, prior constitution versions if embedded).
   - For governance dates: `RATIFICATION_DATE` is the original adoption date (if unknown ask or mark TODO), `LAST_AMENDED_DATE` is today if changes are made, otherwise keep previous.
   - `CONSTITUTION_VERSION` must increment according to semantic versioning rules:
     - MAJOR: Backward incompatible governance/principle removals or redefinitions.
     - MINOR: New principle/section added or materially expanded guidance.
     - PATCH: Clarifications, wording, typo fixes, non-semantic refinements.
   - If version bump type ambiguous, propose reasoning before finalizing.

3. Draft the updated constitution content:
   - Replace every placeholder with concrete text (no bracketed tokens left except intentionally retained template slots that the project has chosen not to define yet—explicitly justify any left).
   - Preserve heading hierarchy and comments can be removed once replaced unless they still add clarifying guidance.
   - Ensure each Principle section: succinct name line, paragraph (or bullet list) capturing non‑negotiable rules, explicit rationale if not obvious.
   - Ensure Governance section lists amendment procedure, versioning policy, and compliance review expectations.

4. Consistency propagation checklist (convert prior checklist into active validations):
   - Read `/templates/plan-template.md` and ensure any "Constitution Check" or rules align with updated principles.
   - Read `/templates/spec-template.md` for scope/requirements alignment—update if constitution adds/removes mandatory sections or constraints.
   - Read `/templates/tasks-template.md` and ensure task categorization reflects new or removed principle-driven task types (e.g., observability, versioning, testing discipline).
   - Read each command file in `/templates/commands/*.md` (including this one) to verify no outdated references (agent-specific names like CLAUDE only) remain when generic guidance is required.
   - Read any runtime guidance docs (e.g., `README.md`, `docs/quickstart.md`, or agent-specific guidance files if present). Update references to principles changed.

5. Produce a Sync Impact Report (prepend as an HTML comment at top of the constitution file after update):
   - Version change: old → new
   - List of modified principles (old title → new title if renamed)
   - Added sections
   - Removed sections
   - Templates requiring updates (✅ updated / ⚠ pending) with file paths
   - Follow-up TODOs if any placeholders intentionally deferred.

6. Validation before final output:
   - No remaining unexplained bracket tokens.
   - Version line matches report.
   - Dates ISO format YYYY-MM-DD.
   - Principles are declarative, testable, and free of vague language ("should" → replace with MUST/SHOULD rationale where appropriate).

7. Write the completed constitution back to `/memory/constitution.md` (overwrite).

8. Output a final summary to the user with:
   - New version and bump rationale.
   - Any files flagged for manual follow-up.
   - Suggested commit message (e.g., `docs: amend constitution to vX.Y.Z (principle additions + governance update)`).

[CN]
## 大纲 (Outline)

你正在更新位于 `/memory/constitution.md` 的项目章程。该文件是一个包含方括号占位符（例如 `[PROJECT_NAME]`、`[PRINCIPLE_1_NAME]`）的 **模板**。你的工作是 (a) 收集/推导具体值，(b) 精确填充模板，以及 (c) 将修订内容传播到所有依赖工件中。

请遵循以下执行流程：

1.  **加载位于 `/memory/constitution.md` 的现有章程模板。**
    - 识别每一个形式为 `[ALL_CAPS_IDENTIFIER]`（全大写标识符）的占位符标记。
    - **重要**：用户需要的原则数量可能少于或多于模板中使用的数量。如果指定了数量，请予以尊重——遵循通用模板结构。你需要相应地更新文档。

2.  **收集/推导占位符的值：**
    - 如果用户输入（对话）提供了值，则使用它。
    - 否则从现有代码库上下文（README、文档、嵌入的先前章程版本）中推导。
    - 对于治理日期：`RATIFICATION_DATE` 是最初采用日期（如果未知则询问或标记 TODO），`LAST_AMENDED_DATE` 如果有更改则是今天，否则保持原样。
    - `CONSTITUTION_VERSION` 必须根据语义化版本规则递增：
        - **主版本号 (MAJOR)**：向后不兼容的治理/原则移除或重定义。
        - **次版本号 (MINOR)**：新增原则/章节或实质性扩展了指导方针。
        - **修订号 (PATCH)**：澄清、措辞、拼写修复、非语义层面的优化。
    - 如果版本升级类型模棱两可，在最终确定前提出理由。

3.  **起草更新后的章程内容：**
    - 将每个占位符替换为具体文本（不要留下括号标记，除非项目方选择暂时不定义某些模板槽位——如果是这种情况，必须明确理由）。
    - 保留标题层级；注释在替换后可以删除，除非它们仍能增加清晰的指导意义。
    - 确保每个“原则 (Principle)”部分包含：简洁的名称行、捕捉不可协商规则的段落（或项目符号列表）、明确的理由（如果不明显）。
    - 确保“治理 (Governance)”部分列出修订程序、版本控制策略和合规审查预期。

4.  **一致性传播检查清单（将先前的清单转换为主动验证）：**
    - 阅读 `/templates/plan-template.md`，确保任何“章程检查 (Constitution Check)”或规则与更新后的原则保持一致。
    - 阅读 `/templates/spec-template.md` 以进行范围/需求对齐——如果章程增加/移除了强制性章节或约束，请进行更新。
    - 阅读 `/templates/tasks-template.md`，确保任务分类反映了新的或已移除的原则驱动的任务类型（例如，可观测性、版本控制、测试纪律）。
    - 阅读 `/templates/commands/*.md` 中的每个命令文件（包括本文件），以验证当需要通用指导时，是否存在过时的引用（如仅指代 CLAUDE 等特定智能体名称）。
    - 阅读任何运行时指导文档（例如 `README.md`、`docs/quickstart.md` 或特定智能体的指导文件（如果存在））。更新对已更改原则的引用。

5.  **生成同步影响报告 (Sync Impact Report)**（作为 HTML 注释前置于更新后的章程文件顶部）：
    - 版本变更：旧 → 新
    - 修改的原则列表（旧标题 → 新标题，如果重命名）
    - 新增章节
    - 移除章节
    - 需要更新的模板（✅ 已更新 / ⚠ 待处理）及文件路径
    - 后续 TODOs（如果有任何有意推迟的占位符）。

6.  **最终输出前的验证：**
    - 没有剩余的未解释的括号标记。
    - 版本行与报告匹配。
    - 日期格式为 ISO YYYY-MM-DD。
    - 原则是声明性的、可测试的，且没有含糊不清的语言（“should” → 在适当的地方替换为 MUST/SHOULD 并附带理由）。

7.  **将完成的章程回写到 `/memory/constitution.md`（覆盖）。**

8.  **向用户输出最终摘要，包含：**
    - 新版本号及升级理由.
    - 任何标记为需要人工跟进的文件。
    - 建议的提交信息（例如，`docs: amend constitution to vX.Y.Z (principle additions + governance update)`）。
[/CN]

Formatting & Style Requirements:

- Use Markdown headings exactly as in the template (do not demote/promote levels).
- Wrap long rationale lines to keep readability (<100 chars ideally) but do not hard enforce with awkward breaks.
- Keep a single blank line between sections.
- Avoid trailing whitespace.

[CN]
**格式与样式要求：**

- 严格按照模板使用 Markdown 标题（不要降低/提升层级）。
- 换行长理由以保持可读性（理想情况下 <100 字符），但不要用尴尬的硬换行符强制执行。
- 章节之间保留一个空行。
- 避免尾部空格。
[/CN]

If the user supplies partial updates (e.g., only one principle revision), still perform validation and version decision steps.

If critical info missing (e.g., ratification date truly unknown), insert `TODO(<FIELD_NAME>): explanation` and include in the Sync Impact Report under deferred items.

Do not create a new template; always operate on the existing `/memory/constitution.md` file.
