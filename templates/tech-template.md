# Technical Steering Template

Use this template for `memory/tech.md`.

---

# Technology Steering

## Stack

- **Language**: [e.g., TypeScript 5.0, Python 3.11]
- **Framework**: [e.g., Next.js 14, FastAPI]
- **Database**: [e.g., PostgreSQL, MongoDB]
- **Cache**: [e.g., Redis, N/A]
- **Testing**: [e.g., Vitest, pytest]
- **CI/CD**: [e.g., GitHub Actions]

## Development Principles

### Test-First (NON-NEGOTIABLE)

All implementation MUST follow strict TDD:
1. Tests are written first
2. Tests are validated and approved
3. Tests are confirmed to FAIL (Red phase)
4. Implementation makes tests pass (Green phase)
5. Refactor while keeping tests green

### Simplicity Gate

- Maximum 3 projects for initial implementation
- Additional projects require documented justification
- No future-proofing allowed
- Start simple, add complexity only when proven necessary

### Anti-Abstraction Gate

- Use framework features directly rather than wrapping them
- Single model representation (no DTOs unless mandated)
- No wrapper classes unless adding behavior
- Trust the framework

### Library-First Principle

- Every feature begins as a standalone module
- Modules MUST be self-contained
- Modules MUST be independently testable
- Clear purpose required - no organizational-only modules

## Coding Standards

### Naming
- [Naming convention rules]

### Error Handling
- [Error handling approach]

### Logging
- [Logging requirements]

## Quality Gates

- [ ] All tests pass
- [ ] Code coverage >= [X]%
- [ ] No lint errors
- [ ] Type-safe (no `any` or equivalent)
- [ ] No security vulnerabilities
- [ ] Documentation updated

## Core Data Structures

<!--
  MERMAID ER DIAGRAM IS MANDATORY - NOT OPTIONAL.

  Entity relationships MUST be documented with Mermaid `erDiagram`:
  - Show all entities and their relationships
  - Include cardinality (one-to-one, one-to-many, many-to-many)

  DO NOT use plain text or ASCII art to describe data models - ALWAYS use Mermaid syntax.

  Tables below are supplementary documentation, not replacements for the ER diagram.
-->

### Entity Relationship Overview

```mermaid
erDiagram
    [Entity1] ||--o{ [Entity2] : "relationship"
    [Entity2] ||--|| [Entity3] : "relationship"
```

### Core Entities

#### [Entity Name 1]

**Purpose**: [What this entity represents in the domain]

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | UUID/Int | Yes | Primary identifier |
| [field_name] | [Type] | [Yes/No] | [Description] |
| created_at | Timestamp | Yes | Creation timestamp |
| updated_at | Timestamp | Yes | Last update timestamp |

**Relationships**:
- Has many [Related Entity]
- Belongs to [Parent Entity]

#### [Entity Name 2]

**Purpose**: [What this entity represents]

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | UUID/Int | Yes | Primary identifier |
| [field_name] | [Type] | [Yes/No] | [Description] |

### Data Model Inventory

| Entity | Table/Collection | Description | Key Relationships |
|--------|------------------|-------------|-------------------|
| [Entity 1] | [table_name] | [Brief description] | [Key relationships] |
| [Entity 2] | [table_name] | [Brief description] | [Key relationships] |

### Value Objects / DTOs

| Name | Purpose | Fields |
|------|---------|--------|
| [ValueObject1] | [Purpose] | [Key fields] |
| [DTO1] | [Purpose] | [Key fields] |

## Dependency Rules

- [Rules for adding new dependencies]
- [Version pinning policy]
- [Security scanning requirements]