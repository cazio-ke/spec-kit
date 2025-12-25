---
description: Discover workflow - reverse engineer existing projects to generate steering files and product specification
description-cn: 发现工作流 - 逆向工程现有项目以生成指导文件和产品规格说明书
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

## Discover Workflow

This workflow analyzes existing projects to reverse-engineer steering files (`memory/product.md`, `memory/tech.md`, `memory/structure.md`) and generate a comprehensive product specification document.

[CN]
## 发现工作流

此工作流分析现有项目，以逆向工程生成指导文件（`memory/product.md`、`memory/tech.md`、`memory/structure.md`）并生成全面的产品规格说明书。
[/CN]

## Purpose

Bootstrap SDD methodology for existing projects by:
- **Analyzing codebase**: Understand technology stack, architecture, and patterns
- **Extracting product context**: Identify purpose, users, and business logic
- **Documenting structure**: Map project layout and conventions
- **Generating specification**: Create product documentation from code analysis

[CN]
## 目的

通过以下方式为现有项目引导 SDD 方法论：
- **分析代码库**：了解技术栈、架构和模式
- **提取产品上下文**：识别目标、用户和业务逻辑
- **记录结构**：映射项目布局和约定
- **生成规格说明**：从代码分析中创建产品文档
[/CN]

## Operating Constraints

**NON-DESTRUCTIVE**: This workflow only reads and analyzes; it generates new files but does NOT modify existing code.
**USER CONFIRMATION**: All generated files require user review and approval before saving.
**MERMAID FIRST (MANDATORY)**: When documenting flows, processes, sequences, or relationships:
- **MUST** use Mermaid syntax as the primary representation
- **NEVER** use plain text descriptions as a substitute for diagrams
- Supported diagram types: `sequenceDiagram`, `flowchart`, `erDiagram`, `classDiagram`

[CN]
## 操作约束

**非破坏性**：此工作流仅进行读取和分析；它会生成新文件，但**绝不**修改现有代码。
**用户确认**：所有生成的文件在保存前都需要用户审查和批准。
**Mermaid 优先（强制）**：在记录流程、过程、时序或关系时：
- **必须**使用 Mermaid 语法作为主要表示形式
- **绝不**使用纯文本描述来代替图表
- 支持的图表类型：`sequenceDiagram`、`flowchart`、`erDiagram`、`classDiagram`
[/CN]

## Execution Flow

### Step 1: Project Discovery

Scan the project to gather initial context:
- **File System Analysis**: Identify root, monorepo/single structure, config files, source dirs.
- **Version Control Analysis**: Check git history for age, contributors, active areas.

**Output**: Project overview summary for user confirmation.

[CN]
### 第一步：项目发现

扫描项目以收集初始上下文：
- **文件系统分析**：识别根目录、Monorepo/单项目结构、配置文件、源目录。
- **版本控制分析**：检查 Git 历史记录以了解项目时长、贡献者、活跃区域。

**输出**：用于用户确认的项目概览摘要。
[/CN]

### Step 2: Technology Stack Analysis

Analyze dependencies and configuration to determine the tech stack:
- **Dependency Analysis**: Parse manifests (package.json, pyproject.toml, etc.) for frameworks, tools.
- **Configuration Analysis**: Check linting, formatting, environment configs.
- **Infrastructure Detection**: Docker, cloud providers, databases.

**Output**: Technology inventory for `memory/tech.md` generation.

[CN]
### 第二步：技术栈分析

分析依赖项和配置以确定技术栈：
- **依赖分析**：解析清单文件（package.json, pyproject.toml 等）以获取框架、工具。
- **配置分析**：检查 Lint、格式化、环境配置。
- **基础设施检测**：Docker、云提供商、数据库。

**输出**：用于生成 `memory/tech.md` 的技术清单。
[/CN]

### Step 3: Architecture Analysis

Understand the project's architecture and patterns:
- **Directory Structure**: Map hierarchy, patterns (MVC, Clean Arch), module boundaries.
- **Code Patterns**: Naming conventions, API patterns (REST, GraphQL), data access, error handling.
- **Dependency Graph**: Map internal dependencies, circular deps, entry points.

**Output**: Architecture summary for `memory/structure.md` generation.

[CN]
### 第三步：架构分析

了解项目的架构和模式：
- **目录结构**：映射层级、模式（MVC, Clean Arch）、模块边界。
- **代码模式**：命名约定、API 模式（REST, GraphQL）、数据访问、错误处理。
- **依赖图**：映射内部依赖、循环依赖、入口点。

**输出**：用于生成 `memory/structure.md` 的架构摘要。
[/CN]

### Step 4: Product Context Extraction

Understand what the product does and who it serves:
- **Documentation**: Parse README, comments, API docs.
- **Code Semantics**: Analyze routes/controllers, domain models, business logic.
- **Configuration Clues**: Feature flags, localization, permissions.

**Output**: Product context summary for `memory/product.md` generation.

[CN]
### 第四步：产品上下文提取

了解产品的功能及其服务对象：
- **文档**：解析 README、注释、API 文档。
- **代码语义**：分析路由/控制器、领域模型、业务逻辑。
- **配置线索**：特性标志、本地化、权限。

**输出**：用于生成 `memory/product.md` 的产品上下文摘要。
[/CN]

### Step 5: Generate Steering Files

Based on analysis, generate three steering files in the `memory/` directory.

#### A. Generate `memory/product.md`
Fill with:
- **Vision**: Extracted/inferred purpose.
- **Target Users**: Identified from analysis.
- **Business Constraints**: Inferred validation/limits.
- **Success Metrics**: Suggested metrics.
- **Core Business Flows** (MERMAID REQUIRED): `sequenceDiagram` for journeys, `flowchart` for logic.

#### B. Generate `memory/tech.md`
Use `templates/tech-template.md` as a base structure.
**IMPORTANT**:
- Replace prescriptive rules (e.g., "Test-First", "Simplicity Gate") with **OBSERVED PRACTICES** from the codebase.
- Do NOT mandate TDD or specific patterns unless the project actually follows them.
- Fill with:
- **Stack**: Languages, frameworks, DBs, tools.
- **Development Principles**: Inferred actual standards.
- **Coding Standards**: Naming, patterns.
- **Core Data Structures** (MERMAID REQUIRED): `erDiagram` for entity relationships.

#### C. Generate `memory/structure.md`
Fill with:
- **Project Layout**: Actual structure with descriptions.
- **Naming Conventions**: Detected patterns.
- **External Service Interfaces**: REST/WebSocket APIs, integrations.
- **API Patterns**: Route definitions.

[CN]
### 第五步：生成指导文件

基于分析，在 `memory/` 目录下生成三个指导文件。

#### A. 生成 `memory/product.md`
填充内容：
- **愿景**：提取/推导的目的。
- **目标用户**：从分析中识别。
- **业务约束**：推导的验证/限制。
- **成功指标**：建议的指标。
- **核心业务流程**（必须使用 Mermaid）：用户旅程的 `sequenceDiagram`，逻辑的 `flowchart`。

#### B. 生成 `memory/tech.md`
使用 `templates/tech-template.md` 作为基础结构。
**重要**：
- 将规定性规则（如“测试优先”、“简化门槛”）替换为从代码库中**观察到的实践**。
- 除非项目实际上遵循 TDD 或特定模式，否则不要在文档中强制要求。
- 填充内容：
- **栈**：语言、框架、数据库、工具。
- **开发原则**：推导出的实际标准。
- **编码规范**：命名、模式。
- **核心数据结构**（必须使用 Mermaid）：实体关系的 `erDiagram`。

#### C. 生成 `memory/structure.md`
填充内容：
- **项目布局**：带有描述的实际结构。
- **命名约定**：检测到的模式。
- **外部服务接口**：REST/WebSocket API，集成。
- **API 模式**：路由定义。
[/CN]

### Step 6: Generate Product Specification

Generate a comprehensive spec at `specs/000-product-spec/product-spec.md` using the template `templates/product-spec-template.md`.
Key sections to fill based on analysis:
- **Executive Summary**
- **Product Overview**
- **Feature Inventory**
- **Architecture Overview**
- **Technical Summary**
- **API Reference**
- **Quality & Testing**
- **Deployment & Operations**
- **Known Issues & Technical Debt**

[CN]
### 第六步：生成产品规格说明书

使用模板 `templates/product-spec-template.md` 在 `specs/000-product-spec/product-spec.md` 生成综合规格说明书。
基于分析填充的关键部分：
- **执行摘要**
- **产品概览**
- **功能清单**
- **架构概览**
- **技术摘要**
- **API 参考**
- **质量与测试**
- **部署与运维**
- **已知问题与技术债**
[/CN]

### Step 7: Present Results & Interactive Refinement

Display analysis results and generated files to user.
Allow user to:
- Review each file.
- Modify or regenerate sections.
- Ask questions about the analysis.

[CN]
### 第七步：展示结果与交互式优化

向用户展示分析结果和生成的文件。
允许用户：
- 审查每个文件。
- 修改或重新生成部分。
- 询问有关分析的问题。
[/CN]

### Step 8: Save

Check if target files already exist in `memory/` or `specs/`.
- If files exist, **ASK USER**: "Target files already exist. Overwrite them or save with a suffix (e.g., .new.md)?"
- After user confirmation/instruction, save all files.

[CN]
### 第八步：保存

检查目标文件是否已存在于 `memory/` 或 `specs/` 中。
- 如果文件存在，**询问用户**：“目标文件已存在。覆盖它们还是保存为带后缀的新文件（例如 .new.md）？”
- 用户确认/指示后，保存所有文件。
[/CN]
