---
description: Execute the implementation planning workflow using the plan template to generate design artifacts.
description-cn: 使用计划模板执行实施规划工作流，以生成设计产物。
handoffs: 
  - label: Create Tasks
    agent: speckit.tasks
    prompt: Break the plan into tasks
    send: true
  - label: Create Checklist
    agent: speckit.checklist
    prompt: Create a checklist for the following domain...

[CN]
  - label: 创建任务
    agent: speckit.tasks
    prompt: 将计划拆分为任务
    send: true
  - label: 创建检查清单
    agent: speckit.checklist
    prompt: 为以下领域创建检查清单...
[/CN]
scripts:
  sh: scripts/bash/setup-plan.sh --json
  ps: scripts/powershell/setup-plan.ps1 -Json
agent_scripts:
  sh: scripts/bash/update-agent-context.sh __AGENT__
  ps: scripts/powershell/update-agent-context.ps1 -AgentType __AGENT__
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

你**必须**在继续之前考虑用户输入（如果不为空）。
[/CN]

## Outline

1. **Setup**: Run `{SCRIPT}` from repo root and parse JSON for FEATURE_SPEC, IMPL_PLAN, SPECS_DIR, BRANCH. For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

2. **Load context**: Read FEATURE_SPEC, `/memory/constitution.md`. Read `/memory/product.md`, `/memory/tech.md`, and `/memory/structure.md` (only if they exist). Load IMPL_PLAN file (do not reset).

3. **Execute plan workflow**: Read and update the IMPL_PLAN file. Follow the structure in the file to:
   - Fill Technical Context (mark unknowns as "NEEDS CLARIFICATION")
   - Fill Constitution Check section from constitution
   - Evaluate gates (ERROR if violations unjustified)
   - Phase 0: Generate research.md (resolve all NEEDS CLARIFICATION)
   - Phase 1: Generate design.md, domain-model.md (if needed)
   - Phase 2: Generate contracts/, quickstart.md (if integration docs needed)
   - Phase 2: Update agent context by running the agent script
   - Re-evaluate Constitution Check post-design

4. **Stop and report**: Command ends after Phase 3 planning. Report branch, IMPL_PLAN path, and generated artifacts.

[CN]
## 大纲 (Outline)

1.  **设置 (Setup)**：从仓库根目录运行 `{SCRIPT}` 并解析 JSON 以获取 FEATURE_SPEC（功能规范）、IMPL_PLAN（实施计划）、SPECS_DIR（规范目录）、BRANCH（分支）。对于参数中的单引号，例如 "I'm Groot"，请使用转义语法：例如 'I'\''m Groot'（或者如果可能，使用 double-quote，双引号："I'm Groot"）。

2.  **加载上下文 (Load context)**：读取 FEATURE_SPEC、`/memory/constitution.md`。读取 `/memory/product.md`、`/memory/tech.md` 和 `/memory/structure.md`（仅当它们存在时）。加载 IMPL_PLAN 文件（不要重置）。

3.  **执行计划工作流 (Execute plan workflow)**：读取并更新 IMPL_PLAN 文件。遵循文件中的结构以执行以下操作：
    - 填写技术背景 (Technical Context)（将未知项标记为 "NEEDS CLARIFICATION"）
    - 根据章程 (constitution) 填写章程检查 (Constitution Check) 部分
    - 评估门控/关卡 (gates)（如果违规且无正当理由则报错）
    - 阶段 0：生成 research.md（解决所有 NEEDS CLARIFICATION）
    - 阶段 1：生成 design.md，domain-model.md（如果需要）
    - 阶段 2：生成 contracts/，以及 quickstart.md（如果需要集成说明）
    - 阶段 2：通过运行 agent 脚本更新 agent 上下文
    - 在设计完成后重新评估章程检查 (Constitution Check)

4.  **停止并报告 (Stop and report)**：命令在阶段 3 规划后结束。报告分支、IMPL_PLAN 路径和生成的产物。
[/CN]

## Phases

### Phase 0: Outline & Research

1. **Extract unknowns from Technical Context** above:
   - For each NEEDS CLARIFICATION → research task
   - For each dependency → best practices task
   - For each integration → patterns task

2. **Generate and dispatch research agents**:

   ```text
   For each unknown in Technical Context:
     Task: "Research {unknown} for {feature context}"
   For each technology choice:
     Task: "Find best practices for {tech} in {domain}"
   ```

3. **Consolidate findings** in `research.md` using format:
   - Decision: [what was chosen]
   - Rationale: [why chosen]
   - Alternatives considered: [what else evaluated]

**Output**: research.md with all NEEDS CLARIFICATION resolved

[CN]
## 阶段 (Phases)

### 阶段 0：大纲与研究 (Phase 0: Outline & Research)

1.  **从上方的技术背景中提取未知项**：
    - 对于每个 NEEDS CLARIFICATION → 研究任务
    - 对于每个依赖项 → 最佳实践任务
    - 对于每个集成 → 模式任务

2.  **生成并分发研究 Agent**：

    ```text
    对于技术背景中的每个未知项：
      任务："针对 {feature context} 研究 {unknown}"
    对于每个技术选择：
      任务："查找 {domain} 中 {tech} 的最佳实践"
    ```

3.  **在 `research.md` 中汇总发现**，使用以下格式：
    - 决策 (Decision)：[选择了什么]
    - 理由 (Rationale)：[为什么选择]
    - 考虑的替代方案 (Alternatives considered)：[还评估了什么]

**输出**：解决了所有 NEEDS CLARIFICATION 的 research.md
[/CN]

### Phase 1: Design

**Prerequisites:** `research.md` complete

1. **Extract entities from feature spec** → `data-model.md`:
   - Entity name, fields, relationships
   - Validation rules from requirements
   - State transitions if applicable

2. **Consider IMPL_DESIGN guidance**:
   - Reference Section 2: Design Background & Boundaries (background, objectives, boundaries)
   - Reference Section 3: Technical Specifications & Constraints (key features, non-functional requirements)
   - Reference Section 4.0: Research Conclusion Summary (tech stack, resolved unknowns)
   - Reference Section 4.1: System Context Diagram (system boundaries, external entities)
   - Reference Section 4.2: Impact Analysis (business processes, upstream/downstream systems, performance impact)
   - Reference Section 4.3: Key Design Decisions (using ADR format)

3. **Generate `design.md`**:
   - Follow the structure of `design-template.md`
   - Core content (required):
     - Technical Specifications (Section 3)
     - Research Summary (Section 4.0)
     - System Context Diagram (Section 4.1)
     - Key Design Decisions (Section 4.3): record important decisions in ADR format
   - Optional extended content:
     - Impact Analysis (Section 4.2)
     - Domain Model Diagram (Section 4.4): UML class diagram, refer to `data-model.md` for detailed fields
     - Specialized Design (Section 4.5) - e.g., state diagrams, sequence diagrams

**Output**: design.md, data-model.md

**Key rules**:
- Use absolute paths
- ERROR on gate failures or unresolved clarifications
- Strictly follow IMPL_DESIGN structure and format
- Prioritize core content, extend optional content as needed
- Domain model must clearly annotate entities

[CN]
### 阶段 1：设计 (Phase 1: Design)

**前置条件：** `research.md` 已完成

1.  **从功能规范中提取实体** → `data-model.md`：
    - 实体名称、字段、关系
    - 来自需求的验证规则
    - 状态流转（如果适用）

2.  **参考 IMPL_DESIGN 指引**：
    - 参考第 2 节：设计背景与边界（背景、目标、实现边界）
    - 参考第 3 节：技术规格与约束（关键功能解读、非功能性要求）
    - 参考第 4.0 节：研究结论总结（核心选型、未知项解决）
    - 参考第 4.1 节：系统上下文图（系统边界、外部实体）
    - 参考第 4.2 节：影响分析（业务流程、上游/下游系统、性能影响）
    - 参考第 4.3 节：关键设计决策（使用 ADR 格式）

3.  **生成 `design.md`**：
    - 遵循 `design-template.md` 的结构
    - 核心内容（必填）：
        - 技术规格（第 3 节）
        - 研究总结（第 4.0 节）
        - 系统上下文图（第 4.1 节）
        - 关键设计决策（第 4.3 节）：以 ADR 格式记录重要决策
    - 可选扩展内容：
        - 影响分析（第 4.2 节）
        - 领域模型图（第 4.4 节）：UML 类图，详细字段请参考 `data-model.md`
        - 专项设计（第 4.5 节）：如状态图、时序图

**输出**：design.md, data-model.md

**关键规则**：
- 使用绝对路径
- 如果门控失败或存在未解决的澄清项，则报错 (ERROR)
- 严格遵守 IMPL_DESIGN 的结构和格式
- 优先完成核心内容，根据需要扩展可选内容
- 领域模型必须清晰标注实体
[/CN]

### Phase 2: Contracts

**Prerequisites:** `design.md` and `data-model.md` (if needed) complete

1. **Generate API contracts** from functional requirements:
   - For each user action → endpoint
   - Use standard REST/GraphQL patterns
   - Output OpenAPI/GraphQL schema to `/contracts/`

2. **Generate quickstart.md**:
   - Provide quick reference for developers
   - Include key endpoints, data models, and usage examples

3. **Agent context update**:
   - Run `{AGENT_SCRIPT}`
   - These scripts detect which AI agent is in use
   - Update the appropriate agent-specific context file
   - Add only new technology from current plan
   - Preserve manual additions between markers

**Output**: /contracts/*, quickstart.md (optional), agent-specific file

[CN]
### 阶段 2：契约 (Phase 2: Contracts)

**前置条件：** `design.md` 和 `data-model.md`（如果需要）已完成

1.  **从功能需求生成 API 契约**：
    - 对于每个用户动作 → 端点
    - 使用标准的 REST/GraphQL 模式
    - 将 OpenAPI/GraphQL 模式输出到 `/contracts/`

2.  **生成 quickstart.md**：
    - 为开发人员提供快速参考
    - 包含关键端点、数据模型和使用示例

3.  **Agent 上下文更新**：
    - 运行 `{AGENT_SCRIPT}`
    - 这些脚本会检测正在使用的是哪个 AI Agent
    - 更新相应的 Agent 特定上下文文件
    - 仅添加当前计划中的新技术
    - 保留标记之间的手动添加内容

**输出**：/contracts/*, quickstart.md（可选）, Agent 特定文件
[/CN]

## Key rules

- Use absolute paths
- ERROR on gate failures or unresolved clarifications

[CN]
## 关键规则

- 使用绝对路径
- 如果门控失败或存在未解决的澄清项，则报错 (ERROR)
[/CN]
