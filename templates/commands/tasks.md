---
description: Generate an actionable, dependency-ordered tasks.md for the feature based on available design artifacts.
description-cn: 基于现有的设计工件，生成一份可执行的、按依赖顺序排列的 tasks.md。
handoffs: 
  - label: Analyze For Consistency
    label-cn: 分析一致性
    agent: speckit.analyze
    prompt: Run a project analysis for consistency
    prompt-cn: 运行项目一致性分析
    send: true
  - label: Implement Project
    label-cn: 实施项目
    agent: speckit.implement
    prompt: Start the implementation in phases
    prompt-cn: 分阶段开始实施
    send: true
scripts:
  sh: scripts/bash/check-prerequisites.sh --json
  ps: scripts/powershell/check-prerequisites.ps1 -Json
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

在继续之前，你 **必须** 考虑用户输入（如果不为空）。
[/CN]

## Outline

1. **Setup**: Run `{SCRIPT}` from repo root and parse FEATURE_DIR and AVAILABLE_DOCS list. All paths must be absolute. For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

2. **Load design documents**: Read from FEATURE_DIR:
   - **Required**: plan.md (tech stack, libraries, structure), spec.md (user stories with priorities)
   - **Optional**: data-model.md (entities), contracts/ (API endpoints), research.md (decisions), quickstart.md (test scenarios)
   - Note: Not all projects have all documents. Generate tasks based on what's available.

3. **Execute task generation workflow**:
   - Load plan.md and extract tech stack, libraries, project structure
   - Load spec.md and extract user stories with their priorities (P1, P2, P3, etc.)
   - If data-model.md exists: Extract entities and map to user stories
   - If contracts/ exists: Map endpoints to user stories
   - If research.md exists: Extract decisions for setup tasks
   - Generate tasks organized by user story (see Task Generation Rules below)
   - Generate dependency graph showing user story completion order
   - Create parallel execution examples per user story
   - Validate task completeness (each user story has all needed tasks, independently testable)

4. **Generate tasks.md**: Use `templates/tasks-template.md` as structure, fill with:
   - Correct feature name from plan.md
   - Phase 1: Setup tasks (project initialization)
   - Phase 2: Foundational tasks (blocking prerequisites for all user stories)
   - Phase 3+: One phase per user story (in priority order from spec.md)
   - Each phase includes: story goal, independent test criteria, tests (if requested), implementation tasks
   - Final Phase: Polish & cross-cutting concerns
   - All tasks must follow the strict checklist format (see Task Generation Rules below)
   - Clear file paths for each task
   - Dependencies section showing story completion order
   - Parallel execution examples per story
   - Implementation strategy section (MVP first, incremental delivery)

5. **Report**: Output path to generated tasks.md and summary:
   - Total task count
   - Task count per user story
   - Parallel opportunities identified
   - Independent test criteria for each story
   - Suggested MVP scope (typically just User Story 1)
   - Format validation: Confirm ALL tasks follow the checklist format (checkbox, ID, labels, file paths)

Context for task generation: {ARGS}

The tasks.md should be immediately executable - each task must be specific enough that an LLM can complete it without additional context.

[CN]
## 大纲 (Outline)

1.  **设置 (Setup)**：从仓库根目录运行 `{SCRIPT}` 并解析 FEATURE_DIR（功能目录）和 AVAILABLE_DOCS（可用文档）列表。所有路径必须是绝对路径。对于参数中的单引号（如 "I'm Groot"），使用转义语法：例如 `'I'\''m Groot'`（或者如果可能，使用双引号："I'm Groot"）。

2.  **加载设计文档 (Load design documents)**：从 FEATURE_DIR 读取：
    - **必须**：plan.md（技术栈、库、结构），spec.md（带有优先级的用户故事）
    - **可选**：data-model.md（实体），contracts/（API 端点），research.md（决策），quickstart.md（测试场景）
    - 注意：并非所有项目都有所有文档。请根据可用内容生成任务。

3.  **执行任务生成工作流 (Execute task generation workflow)**：
    - 加载 plan.md 并提取技术栈、库、项目结构
    - 加载 spec.md 并提取用户故事及其优先级（P1, P2, P3 等）
    - 如果 data-model.md 存在：提取实体并映射到用户故事
    - 如果 contracts/ 存在：将端点映射到用户故事
    - 如果 research.md 存在：提取设置任务的决策
    - 按用户故事组织生成任务（参见下方的“任务生成规则”）
    - 生成显示用户故事完成顺序的依赖图
    - 为每个用户故事创建并行执行示例
    - 验证任务完整性（每个用户故事都包含所有必需的任务，且可独立测试）

4.  **生成 tasks.md (Generate tasks.md)**：使用 `templates/tasks-template.md` 作为结构，填充以下内容：
    - 来自 plan.md 的正确功能名称
    - 阶段 1：设置任务（项目初始化）
    - 阶段 2：基础任务（所有用户故事的阻塞性先决条件）
    - 阶段 3+：每个用户故事一个阶段（按 spec.md 中的优先级顺序）
    - 每个阶段 includes：故事目标、独立测试标准、测试（如果被要求）、实施任务
    - 最终阶段：打磨与横切关注点 (Polish & cross-cutting concerns)
    - 所有任务必须遵循严格的清单格式（参见下方的“任务生成规则”）
    - 每个任务都要有清晰的文件路径
    - 显示故事完成顺序的依赖关系部分
    - 每个故事的并行执行示例
    - 实施策略部分（MVP 优先，增量交付）

5.  **报告 (Report)**：输出生成的 tasks.md 的路径和摘要：
    - 总任务数
    - 每个用户故事的任务数
    - 识别出的并行机会
    - 每个故事的独立测试标准
    - 建议的 MVP 范围（通常仅包含用户故事 1）
    - 格式验证：确认**所有**任务都遵循清单格式（复选框、ID、标签、文件路径）

任务生成上下文：{ARGS}

生成的 tasks.md 应该可以立即执行——每个任务都必须足够具体，以便 LLM（大语言模型）无需额外上下文即可完成。
[/CN]

## Task Generation Rules

**CRITICAL**: Tasks MUST be organized by user story to enable independent implementation and testing.

**Tests are OPTIONAL**: Only generate test tasks if explicitly requested in the feature specification or if user requests TDD approach.

### Checklist Format (REQUIRED)

Every task MUST strictly follow this format:

```text
- [ ] [TaskID] [P?] [Story?] Description with file path
```

**Format Components**:

1. **Checkbox**: ALWAYS start with `- [ ]` (markdown checkbox)
2. **Task ID**: Sequential number (T001, T002, T003...) in execution order
3. **[P] marker**: Include ONLY if task is parallelizable (different files, no dependencies on incomplete tasks)
4. **[Story] label**: REQUIRED for user story phase tasks only
   - Format: [US1], [US2], [US3], etc. (maps to user stories from spec.md)
   - Setup phase: NO story label
   - Foundational phase: NO story label  
   - User Story phases: MUST have story label
   - Polish phase: NO story label
5. **Description**: Clear action with exact file path

**Examples**:

- ✅ CORRECT: `- [ ] T001 Create project structure per implementation plan`
- ✅ CORRECT: `- [ ] T005 [P] Implement authentication middleware in src/middleware/auth.py`
- ✅ CORRECT: `- [ ] T012 [P] [US1] Create User model in src/models/user.py`
- ✅ CORRECT: `- [ ] T014 [US1] Implement UserService in src/services/user_service.py`
- ❌ WRONG: `- [ ] Create User model` (missing ID and Story label)
- ❌ WRONG: `T001 [US1] Create model` (missing checkbox)
- ❌ WRONG: `- [ ] [US1] Create User model` (missing Task ID)
- ❌ WRONG: `- [ ] T001 [US1] Create model` (missing file path)

### Task Organization

1. **From User Stories (spec.md)** - PRIMARY ORGANIZATION:
   - Each user story (P1, P2, P3...) gets its own phase
   - Map all related components to their story:
     - Models needed for that story
     - Services needed for that story
     - Endpoints/UI needed for that story
     - If tests requested: Tests specific to that story
   - Mark story dependencies (most stories should be independent)

2. **From Contracts**:
   - Map each contract/endpoint → to the user story it serves
   - If tests requested: Each contract → contract test task [P] before implementation in that story's phase

3. **From Data Model**:
   - Map each entity to the user story(ies) that need it
   - If entity serves multiple stories: Put in earliest story or Setup phase
   - Relationships → service layer tasks in appropriate story phase

4. **From Setup/Infrastructure**:
   - Shared infrastructure → Setup phase (Phase 1)
   - Foundational/blocking tasks → Foundational phase (Phase 2)
   - Story-specific setup → within that story's phase

### Phase Structure

- **Phase 1**: Setup (project initialization)
- **Phase 2**: Foundational (blocking prerequisites - MUST complete before user stories)
- **Phase 3+**: User Stories in priority order (P1, P2, P3...)
  - Within each story: Tests (if requested) → Models → Services → Endpoints → Integration
  - Each phase should be a complete, independently testable increment
- **Final Phase**: Polish & Cross-Cutting Concerns

[CN]
## 任务生成规则 (Task Generation Rules)

**关键**：任务 **必须** 按用户故事组织，以实现独立的实施和测试。

**测试是可选的**：只有在功能规范中明确要求或用户要求采用 TDD（测试驱动开发）方法时，才生成测试任务。

### 清单格式（必须遵守）

每个任务 **必须** 严格遵循此格式：

```text
- [ ] [TaskID] [P?] [Story?] 描述及文件路径
```

**格式组成部分**：

1.  **复选框**：始终以 `- [ ]` （markdown 复选框）开头
2.  **任务 ID**：按执行顺序的连续编号（T001, T002, T003...）
3.  **[P] 标记**：**仅**当任务可并行时（不同的文件，不依赖于未完成的任务）包含此标记
4.  **[Story] 标签**：**仅**用户故事阶段的任务需要
    - 格式：[US1], [US2], [US3] 等（映射到 spec.md 中的用户故事）
    - 设置阶段：无故事标签
    - 基础阶段：无故事标签
    - 用户故事阶段：**必须** 有故事标签
    - 打磨阶段：无故事标签
5.  **描述**：清晰的动作和确切的文件路径

**示例**：

- ✅ 正确：`- [ ] T001 根据实施计划创建项目结构`
- ✅ 正确：`- [ ] T005 [P] 在 src/middleware/auth.py 中实施认证中间件`
- ✅ 正确：`- [ ] T012 [P] [US1] 在 src/models/user.py 中创建 User 模型`
- ✅ 正确：`- [ ] T014 [US1] 在 src/services/user_service.py 中实施 UserService`
- ❌ 错误：`- [ ] Create User model`（缺少 ID 和故事标签）
- ❌ 错误：`T001 [US1] Create model`（缺少复选框）
- ❌ 错误：`- [ ] [US1] Create User model`（缺少任务 ID）
- ❌ 错误：`- [ ] T001 [US1] Create model`（缺少文件路径）

### 任务组织 (Task Organization)

1.  **基于用户故事 (spec.md)** - 主要组织方式：
    - 每个用户故事（P1, P2, P3...）都有自己的阶段
    - 将所有相关组件映射到其故事：
        - 该故事所需的模型
        - 该故事所需的服务
        - 该故事所需的端点/UI
        - 如果要求测试：特定于该故事的测试
    - 标记故事依赖关系（大多数故事应该是独立的）

2.  **基于合约/接口 (Contracts)**：
    - 将每个合约/端点 → 映射到它服务的用户故事
    - 如果要求测试：每个合约 → 在该故事阶段实施之前的合约测试任务 [P]

3.  **基于数据模型 (Data Model)**：
    - 将每个实体映射到需要它的用户故事
    - 如果实体服务于多个故事：放在最早的故事或设置阶段
    - 关系 → 适当故事阶段中的服务层任务

4.  **基于设置/基础设施 (Setup/Infrastructure)**：
    - 共享基础设施 → 设置阶段（阶段 1）
    - 基础/阻塞性任务 → 基础阶段（阶段 2）
    - 特定于故事的设置 → 在该故事的阶段内

### 阶段结构 (Phase Structure)

- **阶段 1**：设置（项目初始化）
- **阶段 2**：基础（阻塞性先决条件 - **必须** 在用户故事之前完成）
- **阶段 3+**：按优先级顺序的用户故事（P1, P2, P3...）
    - 在每个故事内：测试（如果要求）→ 模型 → 服务 → 端点 → 集成
    - 每个阶段应该是一个完整的、可独立测试的增量
- **最终阶段**：打磨与横切关注点
[/CN]
