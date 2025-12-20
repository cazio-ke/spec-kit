---
description: Integrate completed feature changes back into global project memory and constitution.
description-cn: 将已完成的功能变更集成回全局项目记忆（Memory）和项目章程（Constitution）。
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

The `/speckit.integrate` command is the final step in the feature development lifecycle. Its purpose is to ensure that insights, architectural changes, and new principles discovered during the development of a specific feature are synchronized back into the project's global documentation.

Follow this execution flow:

1. **Feature Review**:
   - Analyze the completed feature's specification (`spec.md`), implementation plan (`plan.md`), and the actual code changes.
   - Identify what was actually built versus what was originally planned.

2. **Knowledge Extraction**:
   - **Architecture**: Did this feature introduce new components, change existing data flows, or add new external dependencies?
   - **Principles**: Were there any "lessons learned," new coding standards, or architectural constraints identified during implementation that should apply to future features?

3. **Global Artifact Synchronization**:
   - **Update `memory/project.md`**:
     - Incorporate new components into the `Architecture Overview`.
     - Update `System Context` if external integrations were added or changed.
     - Refresh the `Technology Stack` if new tools were introduced.
   - **Update `memory/constitution.md`**:
     - If new non-negotiable rules or principles were identified, add them to the relevant section.
     - Increment the `CONSTITUTION_VERSION` and update `LAST_AMENDED_DATE`.
     - Update the `Sync Impact Report` at the top of the file.

4. **Validation**:
   - Ensure that the updates to global memory do not conflict with existing high-level principles.
   - Verify that the updated `project.md` still accurately reflects the current state of the entire repository.

5. **Final Summary**:
   - Provide a clear report of what was integrated:
     - "Updated Architecture: Added [Component Name]"
     - "Updated Constitution: Added Principle [Principle Name]"
     - "Version Bump: Constitution updated to vX.Y.Z"

[CN]
## 流程大纲

`/speckit.integrate` 命令是功能开发生命周期的最后一步。其目的是确保在特定功能开发过程中发现的见解、架构变更和新准则能够同步回项目的全局文档中。

请遵循以下执行流程：

1. **功能复盘**：
   - 分析已完成功能的规格说明书 (`spec.md`)、实施计划 (`plan.md`) 以及实际的代码变更。
   - 识别实际构建的内容与最初计划的内容之间的差异。

2. **知识提取**：
   - **架构**：此功能是否引入了新组件、更改了现有的数据流或添加了新的外部依赖项？
   - **准则**：在实施过程中是否识别出了任何“经验教训”、新的编码标准或架构约束，且这些内容应适用于未来的功能开发？

3. **全局产物同步**：
   - **更新 `memory/project.md`**：
     - 将新组件整合到 `Architecture Overview` 中。
     - 如果添加或更改了外部集成，请更新 `System Context`。
     - 如果引入了新工具，请刷新 `Technology Stack`。
   - **更新 `memory/constitution.md`**：
     - 如果识别出了新的不可协商规则或准则，请将其添加到相关章节。
     - 升级 `CONSTITUTION_VERSION` 并更新 `LAST_AMENDED_DATE`。
     - 更新文件顶部的 `Sync Impact Report`。

4. **验证**：
   - 确保对全局记忆的更新不会与现有的高层准则冲突。
   - 验证更新后的 `project.md` 是否仍能准确反映整个代码库的当前状态。

5. **最终摘要**：
   - 提供一份清晰的集成报告：
     - “架构更新：添加了 [组件名称]”
     - “准则更新：添加了准则 [准则名称]”
     - “版本升级：项目章程已更新至 vX.Y.Z”
[/CN]

## Guidelines

- Be concise but thorough. 
- Only update global memory with details that have *long-term value* for the project.
- Use the feature's branch name or ID as a reference in the change history where appropriate.

[CN]
## 指南

- 简洁而全面。
- 仅将具有 *长期价值* 的细节更新到全局记忆中。
- 在适当的地方，使用功能的候选分支名称或 ID 作为变更历史中的参考。
[/CN]

