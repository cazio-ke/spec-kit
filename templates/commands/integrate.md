---
description: Integrate completed feature changes back into global project memory and constitution.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

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
   - **Update `.specify/memory/project.md`**:
     - Incorporate new components into the `Architecture Overview`.
     - Update `System Context` if external integrations were added or changed.
     - Refresh the `Technology Stack` if new tools were introduced.
   - **Update `.specify/memory/constitution.md`**:
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

## Guidelines

- Be concise but thorough. 
- Only update global memory with details that have *long-term value* for the project.
- Use the feature's branch name or ID as a reference in the change history where appropriate.

