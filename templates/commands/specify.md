---
description: Create or update the feature specification from a natural language feature description.
description-cn: 根据自然语言功能描述创建或更新功能规范。
handoffs: 
  - label: Build Technical Plan
    agent: speckit.plan
    prompt: Create a plan for the spec. I am building with...
  - label: Clarify Spec Requirements
    agent: speckit.clarify
    prompt: Clarify specification requirements
    send: true

[CN]
  - label: 构建技术计划
    agent: speckit.plan
    prompt: 为该规范制定计划。我正在使用的技术栈是...
  - label: 澄清规范需求
    agent: speckit.clarify
    prompt: 澄清规范需求
    send: true
[/CN]
scripts:
  sh: scripts/bash/create-new-feature.sh --json "{ARGS}"
  ps: scripts/powershell/create-new-feature.ps1 -Json "{ARGS}"
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

如果用户输入不为空，你 **必须** 在继续之前参考该输入。
[/CN]

## Outline

The text the user typed after `/speckit.specify` in the triggering message **is** the feature description. Assume you always have it available in this conversation even if `{ARGS}` appears literally below. Do not ask the user to repeat it unless they provided an empty command.

Given that feature description, do this:

1. **Generate a concise short name** (2-4 words) for the branch:
   - Analyze the feature description and extract the most meaningful keywords
   - Create a 2-4 word short name that captures the essence of the feature
   - Use action-noun format when possible (e.g., "add-user-auth", "fix-payment-bug")
   - Preserve technical terms and acronyms (OAuth2, API, JWT, etc.)
   - Keep it concise but descriptive enough to understand the feature at a glance
   - Examples:
     - "I want to add user authentication" → "user-auth"
     - "Implement OAuth2 integration for the API" → "oauth2-api-integration"
     - "Create a dashboard for analytics" → "analytics-dashboard"
     - "Fix payment processing timeout bug" → "fix-payment-timeout"

2. **Check for existing branches before creating new one**:

   a. First, fetch all remote branches to ensure we have the latest information:

      ```bash
      git fetch --all --prune
      ```

   b. Find the highest feature number across all sources for the short-name:
      - Remote branches: `git ls-remote --heads origin | grep -E 'refs/heads/[0-9]+-<short-name>$'`
      - Local branches: `git branch | grep -E '^[* ]*[0-9]+-<short-name>$'`
      - Specs directories: Check for directories matching `specs/[0-9]+-<short-name>`

   c. Determine the next available number:
      - Extract all numbers from all three sources
      - Find the highest number N
      - Use N+1 for the new branch number

   d. Run the script `{SCRIPT}` with the calculated number and short-name:
      - Pass `--number N+1` and `--short-name "your-short-name"` along with the feature description
      - Bash example: `{SCRIPT} --json --number 5 --short-name "user-auth" "Add user authentication"`
      - PowerShell example: `{SCRIPT} -Json -Number 5 -ShortName "user-auth" "Add user authentication"`

   **IMPORTANT**:
   - Check all three sources (remote branches, local branches, specs directories) to find the highest number
   - Only match branches/directories with the exact short-name pattern
   - If no existing branches/directories found with this short-name, start with number 1
   - You must only ever run this script once per feature
   - The JSON is provided in the terminal as output - always refer to it to get the actual content you're looking for
   - The JSON output will contain BRANCH_NAME and SPEC_FILE paths
   - For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot")

3. Load `templates/spec-template.md` to understand required sections.

4. Follow this execution flow:

    1. Parse user description from Input
       If empty: ERROR "No feature description provided"
    2. Extract key concepts from description
       Identify: actors, actions, data, constraints
    3. For unclear aspects:
       - Make informed guesses based on context and industry standards
       - Only mark with [NEEDS CLARIFICATION: specific question] if:
         - The choice significantly impacts feature scope or user experience
         - Multiple reasonable interpretations exist with different implications
         - No reasonable default exists
       - **LIMIT: Maximum 3 [NEEDS CLARIFICATION] markers total**
       - Prioritize clarifications by impact: scope > security/privacy > user experience > technical details
    4. Fill User Scenarios & Testing section
       If no clear user flow: ERROR "Cannot determine user scenarios"
    5. Generate Functional Requirements
       Each requirement must be testable
       Use reasonable defaults for unspecified details (document assumptions in Assumptions section)
    6. Define Success Criteria
       Create measurable, technology-agnostic outcomes
       Include both quantitative metrics (time, performance, volume) and qualitative measures (user satisfaction, task completion)
       Each criterion must be verifiable without implementation details
    7. Identify Key Entities (if data involved)
    8. Return: SUCCESS (spec ready for planning)

5. Write the specification to SPEC_FILE using the template structure, replacing placeholders with concrete details derived from the feature description (arguments) while preserving section order and headings.

[CN]
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
    - 如果没有找到具有此短名称的现有分支/目录，则从编号 1 开始。
    - 每一个功能你只能运行一次此脚本。
    - 脚本提供的 JSON 在终端中输出——请始终参考它以获取你所需的内容。
    - JSON 输出将包含 BRANCH_NAME 和 SPEC_FILE 路径。
    - 对于参数中的单引号（如 "I'm Groot"），使用转义语法：例如 `'I'\''m Groot'`（或者如果可能，使用双引号：`"I'm Groot"`）。

3. 加载 `templates/spec-template.md` 以了解必需的章节。

4. 遵循此执行流程：

    1. 从输入中解析用户描述。如果为空：报错 (ERROR) "No feature description provided"。
    2. 从描述中提取关键概念。识别：参与者、动作、数据、约束。
    3. 对于不明确的方面：
       - 根据上下文和行业标准做出明智的推测。
       - 仅在以下情况下使用 `[NEEDS CLARIFICATION: specific question]`（需要澄清）进行标记：
         - 该选择会显著影响功能范围或用户体验。
         - 存在多种具有不同含义的合理解释。
         - 不存在合理的默认设置。
       - **限制：总共最多 3 个 [NEEDS CLARIFICATION] 标记。**
       - 按影响程度对澄清进行优先级排序：范围 > 安全/隐私 > 用户体验 > 技术细节。
    4. 填写“用户场景与测试”部分。如果没有明确的用户流程：报错 (ERROR) "Cannot determine user scenarios"。
    5. 生成“功能需求”。每项需求都必须是可测试的。对未指定的细节使用合理的默认值（在“假设”部分记录假设）。
    6. 定义“成功标准”。创建可衡量的、与技术无关的结果。包括定量指标（时间、性能、容量）和定性衡量标准（用户满意度、任务完成情况）。每项标准都必须在没有实现细节的情况下可验证。
    7. 识别“关键实体”（如果涉及数据）。
    8. 返回：成功 (SUCCESS)（规范已准备好进行规划）。

5. 使用模板结构将规范写入 SPEC_FILE，将占位符替换为从功能描述（参数）中推导出的具体细节，同时保留章节顺序和标题。
[/CN]

6. **Specification Quality Validation**: After writing the initial spec, validate it against quality criteria:

   a. **Create Spec Quality Checklist**: Generate a checklist file at `FEATURE_DIR/checklists/requirements.md` using the checklist template structure with these validation items:

      ```markdown
      # Specification Quality Checklist: [FEATURE NAME]
      
      **Purpose**: Validate specification completeness and quality before proceeding to planning
      **Created**: [DATE]
      **Feature**: [Link to spec.md]
      
      ## Content Quality
      
      - [ ] No implementation details (languages, frameworks, APIs)
      - [ ] Focused on user value and business needs
      - [ ] Written for non-technical stakeholders
      - [ ] All mandatory sections completed
      
      ## Requirement Completeness
      
      - [ ] No [NEEDS CLARIFICATION] markers remain
      - [ ] Requirements are testable and unambiguous
      - [ ] Success criteria are measurable
      - [ ] Success criteria are technology-agnostic (no implementation details)
      - [ ] All acceptance scenarios are defined
      - [ ] Edge cases are identified
      - [ ] Scope is clearly bounded
      - [ ] Dependencies and assumptions identified
      
      ## Feature Readiness
      
      - [ ] All functional requirements have clear acceptance criteria
      - [ ] User scenarios cover primary flows
      - [ ] Feature meets measurable outcomes defined in Success Criteria
      - [ ] No implementation details leak into specification
      
      ## Notes
      
      - Items marked incomplete require spec updates before `/speckit.clarify` or `/speckit.plan`
      ```

   b. **Run Validation Check**: Review the spec against each checklist item:
      - For each item, determine if it passes or fails
      - Document specific issues found (quote relevant spec sections)

   c. **Handle Validation Results**:

      - **If all items pass**: Mark checklist complete and proceed to step 6

      - **If items fail (excluding [NEEDS CLARIFICATION])**:
        1. List the failing items and specific issues
        2. Update the spec to address each issue
        3. Re-run validation until all items pass (max 3 iterations)
        4. If still failing after 3 iterations, document remaining issues in checklist notes and warn user

      - **If [NEEDS CLARIFICATION] markers remain**:
        1. Extract all [NEEDS CLARIFICATION: ...] markers from the spec
        2. **LIMIT CHECK**: If more than 3 markers exist, keep only the 3 most critical (by scope/security/UX impact) and make informed guesses for the rest
        3. For each clarification needed (max 3), present options to user in this format:

           ```markdown
           ## Question [N]: [Topic]
           
           **Context**: [Quote relevant spec section]
           
           **What we need to know**: [Specific question from NEEDS CLARIFICATION marker]
           
           **Suggested Answers**:
           
           | Option | Answer | Implications |
           |--------|--------|--------------|
           | A      | [First suggested answer] | [What this means for the feature] |
           | B      | [Second suggested answer] | [What this means for the feature] |
           | C      | [Third suggested answer] | [What this means for the feature] |
           | Custom | Provide your own answer | [Explain how to provide custom input] |
           
           **Your choice**: _[Wait for user response]_
           ```

        4. **CRITICAL - Table Formatting**: Ensure markdown tables are properly formatted:
           - Use consistent spacing with pipes aligned
           - Each cell should have spaces around content: `| Content |` not `|Content|`
           - Header separator must have at least 3 dashes: `|--------|`
           - Test that the table renders correctly in markdown preview
        5. Number questions sequentially (Q1, Q2, Q3 - max 3 total)
        6. Present all questions together before waiting for responses
        7. Wait for user to respond with their choices for all questions (e.g., "Q1: A, Q2: Custom - [details], Q3: B")
        8. Update the spec by replacing each [NEEDS CLARIFICATION] marker with the user's selected or provided answer
        9. Re-run validation after all clarifications are resolved

   d. **Update Checklist**: After each validation iteration, update the checklist file with current pass/fail status

7. Report completion with branch name, spec file path, checklist results, and readiness for the next phase (`/speckit.clarify` or `/speckit.plan`).

[CN]
6.  **规格质量验证 (Specification Quality Validation)**：编写初始规范后，根据质量标准对其进行验证：

    a. **创建规格质量检查清单**：使用检查清单模板结构，在 `FEATURE_DIR/checklists/requirements.md` 中生成一个检查清单文件，包含以下验证项：

       ```markdown
       # Specification Quality Checklist: [FEATURE NAME]
       
       **Purpose**: Validate specification completeness and quality before proceeding to planning
       **Created**: [DATE]
       **Feature**: [Link to spec.md]
       
       ## Content Quality
       
       - [ ] 无实现细节（语言、框架、API）。
       - [ ] 专注于用户价值和业务需求。
       - [ ] 为非技术利益相关者编写。
       - [ ] 所有必需章节已完成。
       
       ## Requirement Completeness
       
       - [ ] 无 [NEEDS CLARIFICATION]（需要澄清）标记剩余。
       - [ ] 需求是可测试且无歧义的。
       - [ ] 成功标准是可衡量的。
       - [ ] 成功标准与技术无关（无实现细节）。
       - [ ] 定义了所有验收场景。
       - [ ] 识别了边缘情况。
       - [ ] 范围有明确界定。
       - [ ] 识别了依赖项和假设。
       
       ## Feature Readiness
       
       - [ ] 所有功能需求都有明确的验收标准。
       - [ ] 用户场景覆盖了主要流程。
       - [ ] 功能满足成功标准中定义的可衡量结果。
       - [ ] 规范中没有泄露实现细节。
       
       ## Notes
       
       - 标记为未完成的项目需要在运行 `/speckit.clarify` 或 `/speckit.plan` 之前更新规范。
       ```

    b. **运行验证检查**：根据每个检查清单项审查规范：
       - 对于每个项目，确定其是通过还是失败。
       - 记录发现的具体问题（引用相关的规范章节）。

    c. **处理验证结果**：

       - **如果所有项目均通过**：将检查清单标记为完成，并继续执行步骤 6。

       - **如果项目失败（不包括 [NEEDS CLARIFICATION]）**：
         1. 列出失败的项目和具体问题。
         2. 更新规范以解决每个问题。
         3. 重新运行验证，直到所有项目均通过（最多迭代 3 次）。
         4. 如果在 3 次迭代后仍然失败，在检查清单备注中记录剩余问题并警告用户。

       - **如果 [NEEDS CLARIFICATION] 标记仍然存在**：
         1. 从规范中提取所有 `[NEEDS CLARIFICATION: ...]` 标记。
         2. **限制检查**：如果存在 3 个以上的标记，仅保留 3 个最关键的标记（按范围/安全/UX 影响），对其余标记做出明智推测。
         3. 对于每个需要的澄清（最多 3 个），按以下格式向用户展示选项：

            ```markdown
            ## 问题 [N]: [主题]
            
            **上下文**: [引用相关的规范章节]
            
            **我们需要了解**: [来自 NEEDS CLARIFICATION 标记的具体问题]
            
            **建议回答**:
            
            | 选项 | 回答 | 影响 |
            |--------|--------|--------------|
            | A      | [第一个建议回答] | [这对功能意味着什么] |
            | B      | [第二个建议回答] | [这对功能意味着什么] |
            | C      | [第三个建议回答] | [这对功能意味着什么] |
            | Custom | 提供你自己的回答 | [说明如何提供自定义输入] |
            
            **你的选择**: _[等待用户响应]_
            ```

         4. **重要 - 表格格式**：确保 Markdown 表格格式正确：
            - 使用一致的间距，对齐管道符。
            - 每个单元格内容周围应有空格：`| Content |` 而非 `|Content|`。
            - 标题分隔符必须至少有 3 个连字符：`|--------|`。
            - 测试表格在 Markdown 预览中是否能正确渲染。
         5. 顺序编号问题（Q1, Q2, Q3 - 总共最多 3 个）。
         6. 在等待响应前，一并展示所有问题。
         7. 等待用户对所有问题做出选择（例如："Q1: A, Q2: Custom - [details], Q3: B"）。
         8. 通过将每个 [NEEDS CLARIFICATION] 标记替换为用户选择或提供的回答来更新规范。
         9. 解决所有澄清后重新运行验证。

    d. **更新检查清单**：在每次验证迭代后，使用当前的通过/失败状态更新检查清单文件。

7. 报告完成情况，包括分支名称、规范文件路径、检查清单结果，以及下一阶段（`/speckit.clarify` 或 `/speckit.plan`）的就绪状态。
[/CN]

**NOTE:** The script creates and checks out the new branch and initializes the spec file before writing.

## General Guidelines

## Quick Guidelines

- Focus on **WHAT** users need and **WHY**.
- Avoid HOW to implement (no tech stack, APIs, code structure).
- Written for business stakeholders, not developers.
- DO NOT create any checklists that are embedded in the spec. That will be a separate command.

[CN]
## 快速指南

- 专注于用户需要 **什么** (WHAT) 以及 **为什么** (WHY)。
- 避免涉及 **如何** (HOW) 实现（无技术栈、API、代码结构）。
- 为业务利益相关者编写，而非开发人员。
- **不要** 创建嵌入在规范中的任何检查清单。那将是一个单独的命令。
[/CN]

### Section Requirements

- **Mandatory sections**: Must be completed for every feature
- **Optional sections**: Include only when relevant to the feature
- When a section doesn't apply, remove it entirely (don't leave as "N/A")

[CN]
### 章节要求

- **必需章节**：每个功能都必须完成。
- **可选章节**：仅在与功能相关时包含。
- 当某个章节不适用时，请将其完全删除（不要保留为 "N/A"）。
[/CN]

### For AI Generation

When creating this spec from a user prompt:

1. **Make informed guesses**: Use context, industry standards, and common patterns to fill gaps
2. **Document assumptions**: Record reasonable defaults in the Assumptions section
3. **Limit clarifications**: Maximum 3 [NEEDS CLARIFICATION] markers - use only for critical decisions that:
   - Significantly impact feature scope or user experience
   - Have multiple reasonable interpretations with different implications
   - Lack any reasonable default
4. **Prioritize clarifications**: scope > security/privacy > user experience > technical details
5. **Think like a tester**: Every vague requirement should fail the "testable and unambiguous" checklist item
6. **Common areas needing clarification** (only if no reasonable default exists):
   - Feature scope and boundaries (include/exclude specific use cases)
   - User types and permissions (if multiple conflicting interpretations possible)
   - Security/compliance requirements (when legally/financially significant)

[CN]
### 针对 AI 生成

当根据用户提示创建此规范时：

1.  **做出明智的推测**：使用上下文、行业标准和常见模式来填补空白。
2.  **记录假设**：在“假设”部分记录合理的默认值。
3.  **限制澄清**：最多 3 个 `[NEEDS CLARIFICATION]` 标记——仅用于以下关键决策：
    - 显著影响功能范围或用户体验。
    - 存在多种具有不同含义的合理解释。
    - 缺乏任何合理的默认设置。
4.  **优先处理澄清**：范围 > 安全/隐私 > 用户体验 > 技术细节。
5.  **像测试人员一样思考**：每个模糊的需求都应该无法通过“可测试且无歧义”的检查清单项。
6.  **需要澄清的常见领域**（仅在不存在合理默认值时）：
    - 功能范围和边界（包括/排除特定的用例）。
    - 用户类型和权限（如果存在多种可能的冲突解释）。
    - 安全/合规要求（在法律/财务上具有重大意义时）。
[/CN]

**Examples of reasonable defaults** (don't ask about these):

- Data retention: Industry-standard practices for the domain
- Performance targets: Standard web/mobile app expectations unless specified
- Error handling: User-friendly messages with appropriate fallbacks
- Authentication method: Standard session-based or OAuth2 for web apps
- Integration patterns: RESTful APIs unless specified otherwise

[CN]
**合理默认值的示例**（不要询问这些）：

- 数据保留：该领域的行业标准做法。
- 性能目标：除非另有说明，否则为标准的 Web/移动应用预期。
- 错误处理：具有适当回退机制的用户友好型消息。
- 身份验证方法：Web 应用的标准基于会话或 OAuth2。
- 集成模式：除非另有说明，否则为 RESTful API。
[/CN]

### Success Criteria Guidelines

Success criteria must be:

1. **Measurable**: Include specific metrics (time, percentage, count, rate)
2. **Technology-agnostic**: No mention of frameworks, languages, databases, or tools
3. **User-focused**: Describe outcomes from user/business perspective, not system internals
4. **Verifiable**: Can be tested/validated without knowing implementation details

**Good examples**:

- "Users can complete checkout in under 3 minutes"
- "System supports 10,000 concurrent users"
- "95% of searches return results in under 1 second"
- "Task completion rate improves by 40%"

**Bad examples** (implementation-focused):

- "API response time is under 200ms" (too technical, use "Users see results instantly")
- "Database can handle 1000 TPS" (implementation detail, use user-facing metric)
- "React components render efficiently" (framework-specific)
- "Redis cache hit rate above 80%" (technology-specific)

[CN]
### 成功标准指南

成功标准必须是：

1.  **可衡量的**：包含具体的指标（时间、百分比、计数、速率）。
2.  **与技术无关的**：不提及框架、语言、数据库或工具。
3.  **以用户为中心的**：从用户/业务角度描述结果，而非系统内部实现。
4.  **可验证的**：可以在不知道实现细节的情况下进行测试/验证。

**正面示例**：

- “用户可以在 3 分钟内完成结账。”
- “系统支持 10,000 个并发用户。”
- “95% 的搜索在 1 秒内返回结果。”
- “任务完成率提高 40%。”

**负面示例**（专注于实现）：

- “API 响应时间低于 200ms”（技术性太强，请使用“用户可以立即看到结果”）。
- “数据库可以处理 1000 TPS”（实现细节，请使用面向用户的指标）。
- “React 组件渲染效率高”（特定于框架）。
- “Redis 缓存命中率高于 80%”（特定于技术）。
[/CN]
