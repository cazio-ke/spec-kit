---
description: Perform a non-destructive cross-artifact consistency and quality analysis across spec.md, plan.md, and tasks.md after task generation.
description-cn: 对 spec/plan/tasks 进行跨工件一致性校验：1.检测需求覆盖率与任务映射缺口；2.识别重复、歧义及详述不足项；3.强制验证“项目宪法”合规性。输出非破坏性的分析报告与修复指引，防止设计缺陷流入代码实现阶段。
scripts:
  sh: scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks
  ps: scripts/powershell/check-prerequisites.ps1 -Json -RequireTasks -IncludeTasks
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

[CN]
## User Input (用户输入)

```text
$ARGUMENTS
```

如果用户输入不为空，你 **必须** 在继续之前考虑它。
[/CN]

## Goal

Identify inconsistencies, duplications, ambiguities, and underspecified items across the three core artifacts (`spec.md`, `plan.md`, `tasks.md`) before implementation. This command MUST run only after `/speckit.tasks` has successfully produced a complete `tasks.md`.

[CN]
## Goal (目标)

在实施之前，识别三个核心工件（`spec.md`、`plan.md`、`tasks.md`）之间的不一致、重复、歧义和详述不足的项目。此命令必须仅在 `/speckit.tasks` 成功生成完整的 `tasks.md` 之后运行。
[/CN]

## Operating Constraints

**STRICTLY READ-ONLY**: Do **not** modify any files. Output a structured analysis report. Offer an optional remediation plan (user must explicitly approve before any follow-up editing commands would be invoked manually).

**Constitution Authority**: The project constitution (`/memory/constitution.md`) is **non-negotiable** within this analysis scope. Constitution conflicts are automatically CRITICAL and require adjustment of the spec, plan, or tasks—not dilution, reinterpretation, or silent ignoring of the principle. If a principle itself needs to change, that must occur in a separate, explicit constitution update outside `/speckit.analyze`.

[CN]
## Operating Constraints (操作约束)

**严格只读**：**不要** 修改任何文件。输出一份结构化的分析报告。提供可选的补救计划（在手动调用任何后续编辑命令之前，用户必须明确批准）。

**宪法权威**：项目宪法（`/memory/constitution.md`）在本分析范围内是 **不可协商** 的。宪法冲突自动视为 **CRITICAL（严重）** 问题，需要调整 spec、plan 或 tasks——而不是对原则进行淡化、重新解释或默默忽略。如果原则本身需要更改，必须在 `/speckit.analyze` 之外通过单独、显式的宪法更新来进行。
[/CN]

## Execution Steps

### 1. Initialize Analysis Context

Run `{SCRIPT}` once from repo root and parse JSON for FEATURE_DIR and AVAILABLE_DOCS. Derive absolute paths:

- SPEC = FEATURE_DIR/spec.md
- PLAN = FEATURE_DIR/plan.md
- TASKS = FEATURE_DIR/tasks.md

Abort with an error message if any required file is missing (instruct the user to run missing prerequisite command).
For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

[CN]
## Execution Steps (执行步骤)

### 1. Initialize Analysis Context (初始化分析上下文)

从代码库根目录运行一次 `{SCRIPT}` 并解析 JSON 以获取 FEATURE_DIR（功能目录）和 AVAILABLE_DOCS（可用文档）。推导绝对路径：
- SPEC = FEATURE_DIR/spec.md
- PLAN = FEATURE_DIR/plan.md
- TASKS = FEATURE_DIR/tasks.md

如果缺少任何必需文件，请中止并显示错误消息（指示用户运行缺失的先决条件命令）。对于参数中的单引号，如 "I'm Groot"，使用转义语法：例如 'I'\''m Groot'（或者如果可能，使用双引号："I'm Groot"）。
[/CN]

### 2. Load Artifacts (Progressive Disclosure)

Load only the minimal necessary context from each artifact:

**From spec.md:**

- Overview/Context
- Functional Requirements
- Non-Functional Requirements
- User Stories
- Edge Cases (if present)

**From plan.md:**

- Architecture/stack choices
- Data Model references
- Phases
- Technical constraints

**From tasks.md:**

- Task IDs
- Descriptions
- Phase grouping
- Parallel markers [P]
- Referenced file paths

**From constitution:**

- Load `/memory/constitution.md` for principle validation

[CN]
### 2. Load Artifacts (Progressive Disclosure) (加载工件 - 渐进式披露)

仅加载每个工件所需的最小上下文：

**从 spec.md：**
- 概述/背景 (Overview/Context)
- 功能需求 (Functional Requirements)
- 非功能需求 (Non-Functional Requirements)
- 用户故事 (User Stories)
- 边缘情况（如果有）(Edge Cases)

**从 plan.md：**
- 架构/技术栈选择 (Architecture/stack choices)
- 数据模型引用 (Data Model references)
- 阶段 (Phases)
- 技术约束 (Technical constraints)

**从 tasks.md：**
- 任务 ID (Task IDs)
- 描述 (Descriptions)
- 阶段分组 (Phase grouping)
- 并行标记 [P]
- 引用的文件路径 (Referenced file paths)

**从 constitution：**
- 加载 `/memory/constitution.md` 进行原则验证
[/CN]

### 3. Build Semantic Models

Create internal representations (do not include raw artifacts in output):

- **Requirements inventory**: Each functional + non-functional requirement with a stable key (derive slug based on imperative phrase; e.g., "User can upload file" → `user-can-upload-file`)
- **User story/action inventory**: Discrete user actions with acceptance criteria
- **Task coverage mapping**: Map each task to one or more requirements or stories (inference by keyword / explicit reference patterns like IDs or key phrases)
- **Constitution rule set**: Extract principle names and MUST/SHOULD normative statements

[CN]
### 3. Build Semantic Models (构建语义模型)

创建内部表示（不要在输出中包含原始工件）：
- **需求清单**：每个功能 + 非功能需求都有一个稳定的键（基于祈使短语推导 slug；例如，"User can upload file" → `user-can-upload-file`）
- **用户故事/动作清单**：具有验收标准的离散用户动作
- **任务覆盖映射**：将每个任务映射到一个或多个需求或故事（通过关键字/显式引用模式，如 ID 或关键短语进行推断）
- **宪法规则集**：提取原则名称和 MUST/SHOULD 规范性陈述
[/CN]

### 4. Detection Passes (Token-Efficient Analysis)

Focus on high-signal findings. Limit to 50 findings total; aggregate remainder in overflow summary.

#### A. Duplication Detection

- Identify near-duplicate requirements
- Mark lower-quality phrasing for consolidation

#### B. Ambiguity Detection

- Flag vague adjectives (fast, scalable, secure, intuitive, robust) lacking measurable criteria
- Flag unresolved placeholders (TODO, TKTK, ???, `<placeholder>`, etc.)

#### C. Underspecification

- Requirements with verbs but missing object or measurable outcome
- User stories missing acceptance criteria alignment
- Tasks referencing files or components not defined in spec/plan

#### D. Constitution Alignment

- Any requirement or plan element conflicting with a MUST principle
- Missing mandated sections or quality gates from constitution

#### E. Coverage Gaps

- Requirements with zero associated tasks
- Tasks with no mapped requirement/story
- Non-functional requirements not reflected in tasks (e.g., performance, security)

#### F. Inconsistency

- Terminology drift (same concept named differently across files)
- Data entities referenced in plan but absent in spec (or vice versa)
- Task ordering contradictions (e.g., integration tasks before foundational setup tasks without dependency note)
- Conflicting requirements (e.g., one requires Next.js while other specifies Vue)

[CN]
### 4. Detection Passes (Token-Efficient Analysis) (检测过程 - 节省 Token 的分析)

专注于高信号的发现。总数限制在 50 个发现以内；将其余的汇总在溢出摘要中。

#### A. Duplication Detection (重复检测)
- 识别近似重复的需求
- 标记质量较低的措辞以便合并

#### B. Ambiguity Detection (歧义检测)
- 标记缺乏可衡量标准的模糊形容词（fast, scalable, secure, intuitive, robust 等）
- 标记未解决的占位符（TODO, TKTK, ???, `<placeholder>` 等）

#### C. Underspecification (详述不足)
- 只有动词但缺少对象或可衡量结果的需求
- 缺少验收标准对齐的用户故事
- 任务引用了 spec/plan 中未定义的文件或组件

#### D. Constitution Alignment (宪法对齐)
- 任何与 MUST 原则冲突的需求或计划元素
- 缺少宪法规定的必要部分或质量门控

#### E. Coverage Gaps (覆盖缺口)
- 零关联任务的需求
- 没有映射到需求/故事的任务
- 未在任务中反映的非功能需求（例如，性能、安全性）

#### f. Inconsistency (不一致性)
- 术语漂移（同一概念在不同文件中名称不同）
- 计划中引用但在规格中不存在的数据实体（反之亦然）
- 任务顺序矛盾（例如，集成任务在基础设置任务之前且没有依赖说明）
- 冲突的需求（例如，一个要求 Next.js 而另一个指定 Vue）
[/CN]

### 5. Severity Assignment

Use this heuristic to prioritize findings:

- **CRITICAL**: Violates constitution MUST, missing core spec artifact, or requirement with zero coverage that blocks baseline functionality
- **HIGH**: Duplicate or conflicting requirement, ambiguous security/performance attribute, untestable acceptance criterion
- **MEDIUM**: Terminology drift, missing non-functional task coverage, underspecified edge case
- **LOW**: Style/wording improvements, minor redundancy not affecting execution order

[CN]
### 5. Severity Assignment (严重性分配)

使用此启发式方法对发现进行优先级排序：
- **CRITICAL (严重)**：违反宪法 MUST 原则、缺少核心 spec 工件、或阻碍基准功能的零覆盖需求
- **HIGH (高)**：重复或冲突的需求、模糊的安全/性能属性、不可测试的验收标准
- **MEDIUM (中)**：术语漂移、缺少非功能任务覆盖、详述不足的边缘情况
- **LOW (低)**：风格/措辞改进、不影响执行顺序的轻微冗余
[/CN]

### 6. Produce Compact Analysis Report

Output a Markdown report (no file writes) with the following structure:

## Specification Analysis Report

| ID | Category | Severity | Location(s) | Summary | Recommendation |
|----|----------|----------|-------------|---------|----------------|
| A1 | Duplication | HIGH | spec.md:L120-134 | Two similar requirements ... | Merge phrasing; keep clearer version |

(Add one row per finding; generate stable IDs prefixed by category initial.)

**Coverage Summary Table:**

| Requirement Key | Has Task? | Task IDs | Notes |
|-----------------|-----------|----------|-------|

**Constitution Alignment Issues:** (if any)

**Unmapped Tasks:** (if any)

**Metrics:**

- Total Requirements
- Total Tasks
- Coverage % (requirements with >=1 task)
- Ambiguity Count
- Duplication Count
- Critical Issues Count

[CN]
### 6. Produce Compact Analysis Report (生成紧凑分析报告)

输出一份 Markdown 报告（不写入文件），结构如下：

## Specification Analysis Report (规格分析报告)

| ID | Category | Severity | Location(s) | Summary | Recommendation |
|----|----------|----------|-------------|---------|----------------|
| A1 | Duplication | HIGH | spec.md:L120-134 | Two similar requirements ... | Merge phrasing; keep clearer version |
(每个发现添加一行；生成以类别首字母为前缀的稳定 ID。)

**Coverage Summary Table (覆盖率摘要表):**

| Requirement Key | Has Task? | Task IDs | Notes |
|-----------------|-----------|----------|-------|

**Constitution Alignment Issues (宪法对齐问题):** (如果有)

**Unmapped Tasks (未映射的任务):** (如果有)

**Metrics (指标):**
- Total Requirements (总需求数)
- Total Tasks (总任务数)
- Coverage % (requirements with >=1 task) (覆盖率 %)
- Ambiguity Count (歧义计数)
- Duplication Count (重复计数)
- Critical Issues Count (严重问题计数)
[/CN]

### 7. Provide Next Actions

At end of report, output a concise Next Actions block:

- If CRITICAL issues exist: Recommend resolving before `/speckit.implement`
- If only LOW/MEDIUM: User may proceed, but provide improvement suggestions
- Provide explicit command suggestions: e.g., "Run /speckit.specify with refinement", "Run /speckit.plan to adjust architecture", "Manually edit tasks.md to add coverage for 'performance-metrics'"

[CN]
### 7. Provide Next Actions (提供后续行动)

在报告末尾，输出一个简洁的后续行动块：
- 如果存在 CRITICAL 问题：建议在 `/speckit.implement` 之前解决
- 如果只有 LOW/MEDIUM 问题：用户可以继续，但提供改进建议
- 提供明确的命令建议：例如，"Run /speckit.specify with refinement", "Run /speckit.plan to adjust architecture", "Manually edit tasks.md to add coverage for 'performance-metrics'"
[/CN]

### 8. Offer Remediation

Ask the user: "Would you like me to suggest concrete remediation edits for the top N issues?" (Do NOT apply them automatically.)

[CN]
### 8. Offer Remediation (提供补救)

询问用户："Would you like me to suggest concrete remediation edits for the top N issues?"（您希望我为前 N 个问题提供具体的补救编辑建议吗？）（**不要** 自动应用它们。）
[/CN]

## Operating Principles

### Context Efficiency

- **Minimal high-signal tokens**: Focus on actionable findings, not exhaustive documentation
- **Progressive disclosure**: Load artifacts incrementally; don't dump all content into analysis
- **Token-efficient output**: Limit findings table to 50 rows; summarize overflow
- **Deterministic results**: Rerunning without changes should produce consistent IDs and counts

### Analysis Guidelines

- **NEVER modify files** (this is read-only analysis)
- **NEVER hallucinate missing sections** (if absent, report them accurately)
- **Prioritize constitution violations** (these are always CRITICAL)
- **Use examples over exhaustive rules** (cite specific instances, not generic patterns)
- **Report zero issues gracefully** (emit success report with coverage statistics)

[CN]
## Operating Principles (操作原则)

### Context Efficiency (上下文效率)
- **最小化高信号 Token**：专注于可操作的发现，而不是详尽的文档
- **渐进式披露**：增量加载工件；不要将所有内容倾倒进分析中
- **Token 高效输出**：将发现表限制为 50 行；总结溢出内容
- **确定性结果**：在没有更改的情况下重新运行应产生一致的 ID 和计数

### Analysis Guidelines (分析准则)
- **绝不修改文件**（这是只读分析）
- **绝不幻觉缺失的部分**（如果不存在，请准确报告）
- **优先考虑宪法违规**（这些始终是严重的）
- **使用示例而非详尽规则**（引用具体实例，而不是通用模式）
- **优雅地报告零问题**（发出带有覆盖率统计数据的成功报告）
[/CN]

[CN]
## Context

{ARGS}
[/CN]
