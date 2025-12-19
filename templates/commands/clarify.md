---
description: Identify underspecified areas in the current feature spec by asking up to 5 highly targeted clarification questions and encoding answers back into the spec.
description-cn: 识别当前功能规范中未明确的区域，通过提出最多5个高度针对性的澄清问题，并将答案编码回规范中。
handoffs: 
  - label: Build Technical Plan
    agent: speckit.plan
    prompt: Create a plan for the spec. I am building with...

[CN]
  - label: 构建技术计划
    agent: speckit.plan
    prompt: 为该规范创建一个计划。我正在构建...
[/CN]
scripts:
   sh: scripts/bash/check-prerequisites.sh --json --paths-only
   ps: scripts/powershell/check-prerequisites.ps1 -Json -PathsOnly
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

如果用户输入不为空，你**必须**在继续之前考虑它。
[/CN]

## Outline

Goal: Detect and reduce ambiguity or missing decision points in the active feature specification and record the clarifications directly in the spec file.

Note: This clarification workflow is expected to run (and be completed) BEFORE invoking `/speckit.plan`. If the user explicitly states they are skipping clarification (e.g., exploratory spike), you may proceed, but must warn that downstream rework risk increases.

Execution steps:

1. Run `{SCRIPT}` from repo root **once** (combined `--json --paths-only` mode / `-Json -PathsOnly`). Parse minimal JSON payload fields:
   - `FEATURE_DIR`
   - `FEATURE_SPEC`
   - (Optionally capture `IMPL_PLAN`, `TASKS` for future chained flows.)
   - If JSON parsing fails, abort and instruct user to re-run `/speckit.specify` or verify feature branch environment.
   - For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

2. Load the current spec file. Perform a structured ambiguity & coverage scan using this taxonomy. For each category, mark status: Clear / Partial / Missing. Produce an internal coverage map used for prioritization (do not output raw map unless no questions will be asked).

   Functional Scope & Behavior:
   - Core user goals & success criteria
   - Explicit out-of-scope declarations
   - User roles / personas differentiation

   Domain & Data Model:
   - Entities, attributes, relationships
   - Identity & uniqueness rules
   - Lifecycle/state transitions
   - Data volume / scale assumptions

   Interaction & UX Flow:
   - Critical user journeys / sequences
   - Error/empty/loading states
   - Accessibility or localization notes

   Non-Functional Quality Attributes:
   - Performance (latency, throughput targets)
   - Scalability (horizontal/vertical, limits)
   - Reliability & availability (uptime, recovery expectations)
   - Observability (logging, metrics, tracing signals)
   - Security & privacy (authN/Z, data protection, threat assumptions)
   - Compliance / regulatory constraints (if any)

   Integration & External Dependencies:
   - External services/APIs and failure modes
   - Data import/export formats
   - Protocol/versioning assumptions

   Edge Cases & Failure Handling:
   - Negative scenarios
   - Rate limiting / throttling
   - Conflict resolution (e.g., concurrent edits)

   Constraints & Tradeoffs:
   - Technical constraints (language, storage, hosting)
   - Explicit tradeoffs or rejected alternatives

   Terminology & Consistency:
   - Canonical glossary terms
   - Avoided synonyms / deprecated terms

   Completion Signals:
   - Acceptance criteria testability
   - Measurable Definition of Done style indicators

   Misc / Placeholders:
   - TODO markers / unresolved decisions
   - Ambiguous adjectives ("robust", "intuitive") lacking quantification

   For each category with Partial or Missing status, add a candidate question opportunity unless:
   - Clarification would not materially change implementation or validation strategy
   - Information is better deferred to planning phase (note internally)

3. Generate (internally) a prioritized queue of candidate clarification questions (maximum 5). Do NOT output them all at once. Apply these constraints:
    - Maximum of 10 total questions across the whole session.
    - Each question must be answerable with EITHER:
       - A short multiple‑choice selection (2–5 distinct, mutually exclusive options), OR
       - A one-word / short‑phrase answer (explicitly constrain: "Answer in <=5 words").
    - Only include questions whose answers materially impact architecture, data modeling, task decomposition, test design, UX behavior, operational readiness, or compliance validation.
    - Ensure category coverage balance: attempt to cover the highest impact unresolved categories first; avoid asking two low-impact questions when a single high-impact area (e.g., security posture) is unresolved.
    - Exclude questions already answered, trivial stylistic preferences, or plan-level execution details (unless blocking correctness).
    - Favor clarifications that reduce downstream rework risk or prevent misaligned acceptance tests.
    - If more than 5 categories remain unresolved, select the top 5 by (Impact * Uncertainty) heuristic.

4. Sequential questioning loop (interactive):
    - Present EXACTLY ONE question at a time.
    - For multiple‑choice questions:
       - **Analyze all options** and determine the **most suitable option** based on:
          - Best practices for the project type
          - Common patterns in similar implementations
          - Risk reduction (security, performance, maintainability)
          - Alignment with any explicit project goals or constraints visible in the spec
       - Present your **recommended option prominently** at the top with clear reasoning (1-2 sentences explaining why this is the best choice).
       - Format as: `**Recommended:** Option [X] - <reasoning>`
       - Then render all options as a Markdown table:

       | Option | Description |
       |--------|-------------|
       | A | <Option A description> |
       | B | <Option B description> |
       | C | <Option C description> (add D/E as needed up to 5) |
       | Short | Provide a different short answer (<=5 words) (Include only if free-form alternative is appropriate) |

       - After the table, add: `You can reply with the option letter (e.g., "A"), accept the recommendation by saying "yes" or "recommended", or provide your own short answer.`
    - For short‑answer style (no meaningful discrete options):
       - Provide your **suggested answer** based on best practices and context.
       - Format as: `**Suggested:** <your proposed answer> - <brief reasoning>`
       - Then output: `Format: Short answer (<=5 words). You can accept the suggestion by saying "yes" or "suggested", or provide your own answer.`
    - After the user answers:
       - If the user replies with "yes", "recommended", or "suggested", use your previously stated recommendation/suggestion as the answer.
       - Otherwise, validate the answer maps to one option or fits the <=5 word constraint.
       - If ambiguous, ask for a quick disambiguation (count still belongs to same question; do not advance).
       - Once satisfactory, record it in working memory (do not yet write to disk) and move to the next queued question.
    - Stop asking further questions when:
       - All critical ambiguities resolved early (remaining queued items become unnecessary), OR
       - User signals completion ("done", "good", "no more"), OR
       - You reach 5 asked questions.
    - Never reveal future queued questions in advance.
    - If no valid questions exist at start, immediately report no critical ambiguities.

5. Integration after EACH accepted answer (incremental update approach):
    - Maintain in-memory representation of the spec (loaded once at start) plus the raw file contents.
    - For the first integrated answer in this session:
       - Ensure a `## Clarifications` section exists (create it just after the highest-level contextual/overview section per the spec template if missing).
       - Under it, create (if not present) a `### Session YYYY-MM-DD` subheading for today.
    - Append a bullet line immediately after acceptance: `- Q: <question> → A: <final answer>`.
    - Then immediately apply the clarification to the most appropriate section(s):
       - Functional ambiguity → Update or add a bullet in Functional Requirements.
       - User interaction / actor distinction → Update User Stories or Actors subsection (if present) with clarified role, constraint, or scenario.
       - Data shape / entities → Update Data Model (add fields, types, relationships) preserving ordering; note added constraints succinctly.
       - Non-functional constraint → Add/modify measurable criteria in Non-Functional / Quality Attributes section (convert vague adjective to metric or explicit target).
       - Edge case / negative flow → Add a new bullet under Edge Cases / Error Handling (or create such subsection if template provides placeholder for it).
       - Terminology conflict → Normalize term across spec; retain original only if necessary by adding `(formerly referred to as "X")` once.
    - If the clarification invalidates an earlier ambiguous statement, replace that statement instead of duplicating; leave no obsolete contradictory text.
    - Save the spec file AFTER each integration to minimize risk of context loss (atomic overwrite).
    - Preserve formatting: do not reorder unrelated sections; keep heading hierarchy intact.
    - Keep each inserted clarification minimal and testable (avoid narrative drift).

6. Validation (performed after EACH write plus final pass):
   - Clarifications session contains exactly one bullet per accepted answer (no duplicates).
   - Total asked (accepted) questions ≤ 5.
   - Updated sections contain no lingering vague placeholders the new answer was meant to resolve.
   - No contradictory earlier statement remains (scan for now-invalid alternative choices removed).
   - Markdown structure valid; only allowed new headings: `## Clarifications`, `### Session YYYY-MM-DD`.
   - Terminology consistency: same canonical term used across all updated sections.

7. Write the updated spec back to `FEATURE_SPEC`.

8. Report completion (after questioning loop ends or early termination):
   - Number of questions asked & answered.
   - Path to updated spec.
   - Sections touched (list names).
   - Coverage summary table listing each taxonomy category with Status: Resolved (was Partial/Missing and addressed), Deferred (exceeds question quota or better suited for planning), Clear (already sufficient), Outstanding (still Partial/Missing but low impact).
   - If any Outstanding or Deferred remain, recommend whether to proceed to `/speckit.plan` or run `/speckit.clarify` again later post-plan.
   - Suggested next command.

[CN]
## 大纲

目标：检测并减少当前功能规范中的歧义或缺失的决策点，并将澄清内容直接记录在规范文件中。

注意：此澄清工作流预计在调用 `/speckit.plan` 之前运行（并完成）。如果用户明确声明跳过澄清（例如：探索性 Spike），你可以继续，但必须警告下游返工风险会增加。

执行步骤：

1.  从仓库根目录运行 `{SCRIPT}` **一次**（结合 `--json --paths-only` 模式 / `-Json -PathsOnly`）。解析最小 JSON 负载字段：
    - `FEATURE_DIR`
    - `FEATURE_SPEC`
    - （可选捕获 `IMPL_PLAN`, `TASKS` 用于未来的链式流程。）
    - 如果 JSON 解析失败，中止并指示用户重新运行 `/speckit.specify` 或验证功能分支环境。
    - 对于像 "I'm Groot" 这样的参数中的单引号，使用转义语法：例如 `'I'\''m Groot'`（或者如果可能，使用双引号：`"I'm Groot"`）。

2.  加载当前规范文件。使用此分类法执行结构化的歧义和覆盖率扫描。对于每个类别，标记状态：清晰 / 部分 / 缺失。生成用于优先级的内部覆盖率映射（除非不提出任何问题，否则不要输出原始映射）。

    功能范围与行为 (Functional Scope & Behavior)：
    - 核心用户目标与成功标准
    - 明确的“超出范围”声明
    - 用户角色/画像的区分

    领域与数据模型 (Domain & Data Model)：
    - 实体、属性、关系
    - 身份与唯一性规则
    - 生命周期/状态转换
    - 数据量/规模假设

    交互与用户体验流程 (Interaction & UX Flow)：
    - 关键用户旅程/序列
    - 错误/空状态/加载状态
    - 辅助功能或本地化说明

    非功能性质量属性 (Non-Functional Quality Attributes)：
    - 性能（延迟、吞吐量目标）
    - 可扩展性（水平/垂直，限制）
    - 可靠性与可用性（正常运行时间、恢复预期）
    - 可观测性（日志、指标、追踪信号）
    - 安全性与隐私（认证/授权、数据保护、威胁假设）
    - 合规性/监管约束（如有）

    集成与外部依赖 (Integration & External Dependencies)：
    - 外部服务/API 及其故障模式
    - 数据导入/导出格式
    - 协议/版本控制假设

    边缘情况与故障处理 (Edge Cases & Failure Handling)：
    - 消极场景（Negative scenarios）
    - 速率限制/节流
    - 冲突解决（例如，并发编辑）

    约束与权衡 (Constraints & Tradeoffs)：
    - 技术约束（语言、存储、托管）
    - 明确的权衡或被拒绝的替代方案

    术语与一致性 (Terminology & Consistency)：
    - 规范的词汇表术语
    - 避免使用的同义词/已弃用的术语

    完成信号 (Completion Signals)：
    - 验收标准的可测试性
    - 可衡量的“完成定义”（Definition of Done）风格指标

    杂项/占位符 (Misc / Placeholders)：
    - TODO 标记/未解决的决定
    - 缺乏量化的模糊形容词（“健壮的”、“直观的”）

    对于状态为“部分”或“缺失”的每个类别，添加一个候选问题机会，除非：
    - 澄清不会实质性地改变实施或验证策略
    - 信息最好推迟到规划阶段（在内部记录）

3.  （在内部）生成一个优先的候选澄清问题队列（最多 5 个）。不要一次性全部输出。应用这些约束：
    - 整个会话最多 10 个问题。
    - 每个问题必须可以通过以下方式回答：
        - 简短的多项选择（2–5 个不同的、互斥的选项），或者
        - 一个单词/简短词组的答案（明确限制：“回答 <=5 个词”）。
    - 仅包含其答案会实质性影响架构、数据建模、任务分解、测试设计、UX 行为、操作准备就绪或合规性验证的问题。
    - 确保类别覆盖平衡：尝试首先覆盖影响最大的未解决类别；避免在一个高影响区域（例如安全态势）未解决时询问两个低影响的问题。
    - 排除已回答的问题、琐碎的风格偏好或计划级别的执行细节（除非阻碍正确性）。
    - 倾向于那些能降低下游返工风险或防止验收测试不一致的澄清。
    - 如果仍有超过 5 个类别未解决，通过（影响 * 不确定性）启发式方法选择前 5 个。

4.  顺序提问循环（交互式）：
    - 每次**仅**提出一个问题。
    - 对于多项选择题：
        - **分析所有选项**并根据以下内容确定**最合适的选项**：
            - 项目类型的最佳实践
            - 类似实现中的常见模式
            - 风险降低（安全性、性能、可维护性）
            - 与规范中可见的任何明确项目目标或约束的一致性
        - 在顶部显著位置展示你的**推荐选项**，并附带清晰的理由（1-2句解释为什么这是最佳选择）。
        - 格式为：`**推荐：** 选项 [X] - <理由>`
        - 然后将所有选项渲染为 Markdown 表格：

        | 选项 | 描述 |
        |--------|-------------|
        | A | <选项 A 描述> |
        | B | <选项 B 描述> |
        | C | <选项 C 描述> (根据需要添加 D/E，最多 5 个) |
        | Short | 提供不同的简短回答 (<=5 个词) (仅在自由形式替代方案合适时包含) |

        - 在表格之后，添加：`你可以回复选项字母（例如 "A"），通过回复 "yes" 或 "recommended" 接受推荐，或者提供你自己的简短答案。`
    - 对于简答题风格（没有意义的离散选项）：
        - 根据最佳实践和上下文提供你的**建议答案**。
        - 格式为：`**建议：** <你提出的答案> - <简短理由>`
        - 然后输出：`格式：简短回答（<=5个词）。你可以通过回复 "yes" 或 "suggested" 接受建议，或提供你自己的答案。`
    - 用户回答后：
        - 如果用户回复 "yes"、"recommended" 或 "suggested"，则使用你之前陈述的推荐/建议作为答案。
        - 否则，验证答案是否映射到一个选项或符合 <=5 个词的约束。
        - 如果模棱两可，要求快速消除歧义（计数仍属于同一问题；不要推进）。
        - 一旦满意，将其记录在工作内存中（尚未写入磁盘）并移动到下一个排队的问题。
    - 当出现以下情况时停止提出更多问题：
        - 所有关键歧义均已尽早解决（剩余的排队项目变得不必要），或者
        - 用户发出完成信号（“done”、“good”、“no more”），或者
        - 你已达到 5 个提问数量。
    - 永远不要提前透露未来的排队问题。
    - 如果开始时不存在有效问题，立即报告没有关键歧义。

5.  在**每次**接受答案后的集成（增量更新方法）：
    - 维护规范的内存表示（开始时加载一次）加上原始文件内容。
    - 对于本会话中的第一个集成答案：
        - 确保存型 `## Clarifications`（澄清）部分（如果缺失，则根据规范模板在最高级别的上下文/概述部分之后创建它）。
        - 在其下，为今天创建一个 `### Session YYYY-MM-DD` 子标题（如果不存在）。
    - 接受后立即附加一行要点：`- Q: <问题> → A: <最终答案>`。
    - 然后立即将澄清应用到最合适的部分：
        - 功能歧义 → 更新或在“功能需求”中添加要点。
        - 用户交互/角色区分 → 更新“用户故事”或“参与者”子部分（如果存在），包含澄清的角色、约束或场景。
        - 数据形状/实体 → 更新“数据模型”（添加字段、类型、关系），保留顺序；简洁地记录添加的约束。
        - 非功能约束 → 在“非功能/质量属性”部分添加/修改可衡量标准（将模糊形容词转换为指标或明确目标）。
        - 边缘情况/消极流程 → 在“边缘情况/错误处理”下添加新要点（如果模板为此提供了占位符，则创建此类子部分）。
        - 术语冲突 → 在规范中规范化术语；仅在必要时保留原始术语，并添加一次 `(formerly referred to as "X")`。
    - 如果澄清使早先的模棱两可的陈述无效，请替换该陈述而不是重复；不要留下过时的矛盾文本。
    - 在每次集成**后**保存规范文件，以最大程度地降低上下文丢失的风险（原子覆盖）。
    - 保留格式：不要重新排序不相关的部分；保持标题层级完整。
    - 保持每个插入的澄清极简且可测试（避免叙述漂移）。

6.  验证（在每次写入后及最后一遍执行）：
    - 澄清会话包含每个已接受答案的一个要点（无重复）。
    - 总提问（已接受）数 ≤ 5。
    - 更新的部分不包含新答案旨在解决的遗留模糊占位符。
    - 没有保留矛盾的早期陈述（扫描是否移除了现已无效的替代选择）。
    - Markdown structure valid; only allowed new headings: `## Clarifications`, `### Session YYYY-MM-DD`.
    - 术语一致性：在所有更新的部分中使用相同的规范术语。

7.  将更新后的规范写回 `FEATURE_SPEC`。

8.  报告完成（在提问循环结束或提前终止后）：
    - 提问和回答的数量。
    - 更新后的规范路径。
    - 触及的部分（列出名称）。
    - 覆盖率摘要表，列出每个分类法类别的状态：Resolved（已解决，原为部分/缺失并已处理），Deferred（推迟，超出提问配额或更适合规划），Clear（清晰，已足够），Outstanding（未解决，仍为部分/缺失但影响较低）。
    - 如果仍有 Outstanding 或 Deferred，建议是继续进行 `/speckit.plan` 还是稍后在计划后再次运行 `/speckit.clarify`。
    - 建议的下一个命令。
[/CN]

Behavior rules:

- If no meaningful ambiguities found (or all potential questions would be low-impact), respond: "No critical ambiguities detected worth formal clarification." and suggest proceeding.
- If spec file missing, instruct user to run `/speckit.specify` first (do not create a new spec here).
- Never exceed 5 total asked questions (clarification retries for a single question do not count as new questions).
- Avoid speculative tech stack questions unless the absence blocks functional clarity.
- Respect user early termination signals ("stop", "done", "proceed").
- If no questions asked due to full coverage, output a compact coverage summary (all categories Clear) then suggest advancing.
- If quota reached with unresolved high-impact categories remaining, explicitly flag them under Deferred with rationale.

[CN]
行为规则：

- 如果未发现有意义的歧义（或所有潜在问题的影响都很低），回应：“未检测到值得正式澄清的关键歧义。”并建议继续。
- 如果缺少规范文件，指示用户先运行 `/speckit.specify`（不要在此处创建新规范）。
- 总提问数绝不超过 5 个（针对单个问题的澄清重试不计为新问题）。
- 避免推测性的技术栈问题，除非其缺失阻碍了功能清晰度。
- 尊重用户的提前终止信号（“stop”、“done”、“proceed”）。
- 如果由于全覆盖而未提出问题，输出紧凑的覆盖率摘要（所有类别均为 Clear），然后建议推进。
- 如果达到配额但仍有未解决的高影响类别，在 Deferred 下明确标记它们并说明理由。
[/CN]

Context for prioritization: {ARGS}
