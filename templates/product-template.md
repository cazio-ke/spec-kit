# Product Steering Template

Use this template for `memory/product.md`.

---

# Product Steering

## Vision

[What is the product and why does it exist? 1-2 sentences describing the core purpose.]

## Target Users

[Who are the primary users? List personas or user types.]

- **[Persona 1]**: [Description and needs]
- **[Persona 2]**: [Description and needs]

## Business Constraints

[What business rules or limitations must be respected?]

- [Constraint 1]
- [Constraint 2]
- [Constraint 3]

## Success Metrics

[How do we measure success? Include specific, measurable targets.]

- **[Metric 1]**: [Target value]
- **[Metric 2]**: [Target value]
- **[Metric 3]**: [Target value]

## Non-Functional Requirements

### Performance

- [Performance requirement 1]
- [Performance requirement 2]

### Security

- [Security requirement 1]
- [Security requirement 2]

### Compliance

- [Compliance requirement if applicable]

## Core Business Flows

<!--
  MERMAID DIAGRAMS ARE MANDATORY - NOT OPTIONAL.
  Every business flow MUST be documented with Mermaid diagrams:
  - Use `sequenceDiagram` for user journeys, API interactions, service calls
  - Use `flowchart` for decision logic, process flows, state transitions
  Plain text descriptions are SUPPLEMENTARY ONLY, not replacements for diagrams.
  DO NOT use ASCII art or plain text to describe flows - ALWAYS use Mermaid syntax.
-->

### Flow 1: [Primary Business Flow Name]

**Description**: [Brief description of what this flow accomplishes]
**Actors**: [Who participates in this flow]

```mermaid
sequenceDiagram
    participant User
    participant System
    participant [Other]
    User->>System: [Action 1]
    System->>System: [Processing]
    System-->>User: [Response]
```

### Flow 2: [Secondary Business Flow Name]

**Description**: [Brief description]

```mermaid
flowchart TD
    A[Start] --> B{Decision}
    B -->|Yes| C[Action 1]
    B -->|No| D[Action 2]
    C --> E[End]
    D --> E
```

### Business Flow Inventory

| Flow ID | Name | Description | Frequency | Criticality |
|---------|------|-------------|-----------|-------------|
| BF-001 | [Flow Name] | [Brief description] | [Daily/Weekly/etc.] | [High/Medium/Low] |
| BF-002 | [Flow Name] | [Brief description] | [Frequency] | [Criticality] |

## Feature Prioritization

[Guidelines for prioritizing features]

- **P1 (Must Have)**: [Criteria]
- **P2 (Should Have)**: [Criteria]
- **P3 (Nice to Have)**: [Criteria]

