---
description: 在生成任务后，对 spec.md、plan.md 和 tasks.md 进行非破坏性的跨工件一致性和质量分析。
scripts:
  sh: scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks
  ps: scripts/powershell/check-prerequisites.ps1 -Json -RequireTasks -IncludeTasks
---

## User Input (用户输入)

```text
$ARGUMENTS
```

如果用户输入不为空，你 **必须** 在继续之前考虑它。

## Goal (目标)

在实施之前，识别三个核心工件（`spec.md`、`plan.md`、`tasks.md`）之间的不一致、重复、歧义和详述不足的项目。此命令必须仅在 `/speckit.tasks` 成功生成完整的 `tasks.md` 之后运行。

## Operating Constraints (操作约束)

**严格只读**：**不要** 修改任何文件。输出一份结构化的分析报告。提供可选的补救计划（在手动调用任何后续编辑命令之前，用户必须明确批准）。

**宪法权威**：项目宪法（`/memory/constitution.md`）在本分析范围内是 **不可协商** 的。宪法冲突自动视为 **CRITICAL（严重）** 问题，需要调整 spec、plan 或 tasks——而不是对原则进行淡化、重新解释或默默忽略。如果原则本身需要更改，必须在 `/speckit.analyze` 之外通过单独、显式的宪法更新来进行。

## Execution Steps (执行步骤)

### 1. Initialize Analysis Context (初始化分析上下文)

从代码库根目录运行一次 `{SCRIPT}` 并解析 JSON 以获取 FEATURE_DIR（功能目录）和 AVAILABLE_DOCS（可用文档）。推导绝对路径：
- SPEC = FEATURE_DIR/spec.md
- PLAN = FEATURE_DIR/plan.md
- TASKS = FEATURE_DIR/tasks.md

如果缺少任何必需文件，请中止并显示错误消息（指示用户运行缺失的先决条件命令）。对于参数中的单引号，如 "I'm Groot"，使用转义语法：例如 'I'\''m Groot'（或者如果可能，使用双引号："I'm Groot"）。

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

### 3. Build Semantic Models (构建语义模型)

创建内部表示（不要在输出中包含原始工件）：
- **需求清单**：每个功能 + 非功能需求都有一个稳定的键（基于祈使短语推导 slug；例如，"User can upload file" → `user-can-upload-file`）
- **用户故事/动作清单**：具有验收标准的离散用户动作
- **任务覆盖映射**：将每个任务映射到一个或多个需求或故事（通过关键字/显式引用模式，如 ID 或关键短语进行推断）
- **宪法规则集**：提取原则名称和 MUST/SHOULD 规范性陈述

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

#### F. Inconsistency (不一致性)
- 术语漂移（同一概念在不同文件中名称不同）
- 计划中引用但在规格中不存在的数据实体（反之亦然）
- 任务顺序矛盾（例如，集成任务在基础设置任务之前且没有依赖说明）
- 冲突的需求（例如，一个要求 Next.js 而另一个指定 Vue）

### 5. Severity Assignment (严重性分配)

使用此启发式方法对发现进行优先级排序：
- **CRITICAL (严重)**：违反宪法 MUST 原则、缺少核心 spec 工件、或阻碍基准功能的零覆盖需求
- **HIGH (高)**：重复或冲突的需求、模糊的安全/性能属性、不可测试的验收标准
- **MEDIUM (中)**：术语漂移、缺少非功能任务覆盖、详述不足的边缘情况
- **LOW (低)**：风格/措辞改进、不影响执行顺序的轻微冗余

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

### 7. Provide Next Actions (提供后续行动)

在报告末尾，输出一个简洁的后续行动块：
- 如果存在 CRITICAL 问题：建议在 `/speckit.implement` 之前解决
- 如果只有 LOW/MEDIUM 问题：用户可以继续，但提供改进建议
- 提供明确的命令建议：例如，"Run /speckit.specify with refinement", "Run /speckit.plan to adjust architecture", "Manually edit tasks.md to add coverage for 'performance-metrics'"

### 8. Offer Remediation (提供补救)

询问用户："Would you like me to suggest concrete remediation edits for the top N issues?"（您希望我为前 N 个问题提供具体的补救编辑建议吗？）（**不要** 自动应用它们。）

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

## Context (上下文)

{ARGS}
```