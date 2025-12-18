---
description: Analyze the project architecture and system context, updating the project memory.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

You are updating the project architecture documentation at `.specify/memory/project.md`. Your goal is to provide a comprehensive view of the system's structure, context, and technology stack.

Follow this execution flow:

1. **Scan and Analyze**:
   - Explore the codebase to identify the primary programming languages, frameworks, and key libraries.
   - Map the directory structure to understand the high-level component organization.
   - Identify external dependencies (APIs, databases, third-party services).
   - Trace key data flows through the system.

2. **Collect/Derive Architecture Details**:
   - If user input provides specific architectural constraints or context, incorporate it.
   - Infer the `[PROJECT_NAME]` and `[SYSTEM_DESCRIPTION]` from README files and project metadata.
   - Populate the `System Context` section with a description or a Mermaid diagram of external integrations.
   - Detail the `Components` and their responsibilities.
   - Document the `Technology Stack` used in the project.

3. **Draft the Updated Documentation**:
   - Use the template at `.specify/memory/project.md` as your guide.
   - Replace every placeholder `[ALL_CAPS_IDENTIFIER]` with concrete, factual information.
   - Ensure the `LAST_UPDATED_DATE` is set to today (YYYY-MM-DD).

4. **Consistency Check**:
   - Verify that the architecture description aligns with the project's `README.md` and `constitution.md`.
   - Ensure all key technical decisions reflected in the code are captured.

5. **Final Output**:
   - Write the completed architecture documentation back to `.specify/memory/project.md` (overwrite).
   - Provide a summary of the key findings and any major changes made to the documentation.

## Guidelines

- Focus on accuracy and clarity.
- Use Mermaid diagrams where helpful to visualize complex relationships.
- Keep the description technology-focused but accessible.
- If certain details are unknown, mark them as `[UNKNOWN: Description of what is missing]`.

