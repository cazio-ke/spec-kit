---
description: Execute the implementation planning workflow using the plan template to generate design artifacts.
handoffs: 
  - label: Create Tasks
    agent: speckit.tasks
    prompt: Break the plan into tasks
    send: true
  - label: Create Checklist
    agent: speckit.checklist
    prompt: Create a checklist for the following domain...
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

## Outline

1. **Setup**: Run `{SCRIPT}` from repo root and parse JSON for FEATURE_SPEC, IMPL_PLAN, SPECS_DIR, BRANCH. For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

2. **Load context**: Read FEATURE_SPEC, `/memory/constitution.md` and `/memory/architecture.md`(only if it exists). Load IMPL_PLAN template (already copied).

3. **Execute plan workflow**: Follow the structure in IMPL_PLAN template to:
   - Fill Technical Context (mark unknowns as "NEEDS CLARIFICATION")
   - Fill Constitution Check section from constitution
   - Evaluate gates (ERROR if violations unjustified)
   - Phase 0: Generate research.md (resolve all NEEDS CLARIFICATION)
   - Phase 1: Generate design.md, domain-model.md (if needed)
   - Phase 2: Generate contracts/, quickstart.md
   - Phase 2: Update agent context by running the agent script
   - Re-evaluate Constitution Check post-design

4. **Stop and report**: Command ends after Phase 3 planning. Report branch, IMPL_PLAN path, and generated artifacts.

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

### Phase 1: Design

**Prerequisites:** `research.md` complete

1. **Extract entities from feature spec** → `data-model.md`:
   - Entity name, fields, relationships
   - Validation rules from requirements
   - State transitions if applicable

2. **Consider IMPL_DESIGN guidance**:
   - Reference Section 2: Requirements Overview (background, objectives, scope, value)
   - Reference Section 3: Requirements Analysis (feature list, use case diagram, key processes)
   - Reference Section 4.1: System Context Diagram (system boundaries, external entities)
   - Reference Section 4.2: Impact Analysis (business processes, upstream/downstream systems, performance impact)
   - Reference Section 4.3: Key Design Decisions (using ADR format)

3. **Generate `design.md`**:
   - Follow the structure of `design-template.md`
   - Core content (required):
     - Requirements Analysis (Section 3): feature list, use case diagram, key processes
     - System Context Diagram (Section 4.1)
     - Key Design Decisions (Section 4.3): record important decisions in ADR format, including decision background, candidate solutions, selection rationale, and consequences
   - Optional extended content:
     - Non-functional Requirements (Section 3.4)
     - Impact Analysis (Section 4.2)
     - Domain Model Diagram (Section 4.4): UML class diagram, distinguish entities, value objects, and aggregate roots, relationship types and cardinality annotations
     - Specialized Design (Section 4.5) - e.g., state diagrams, sequence diagrams

**Output**: design.md, data-model.md

**Key rules**:
- Use absolute paths
- ERROR on gate failures or unresolved clarifications
- Strictly follow IMPL_DESIGN structure and format
- Prioritize core content, extend optional content as needed
- Domain model must clearly annotate entities

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

**Output**: /contracts/*, quickstart.md, agent-specific file

## Key rules

- Use absolute paths
- ERROR on gate failures or unresolved clarifications
