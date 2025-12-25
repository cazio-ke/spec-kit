# Structure Steering Template

Use this template for `memory/structure.md`.

---

# Structure Steering

## Project Layout

```text
[Define your project structure here]

# Example for web application:
src/
├── components/     # UI components
├── services/       # Business logic
├── models/         # Data models
├── api/            # API routes
├── hooks/          # Custom hooks
├── utils/          # Utility functions
└── types/          # Type definitions

tests/
├── unit/           # Unit tests
├── integration/    # Integration tests
└── e2e/            # End-to-end tests

docs/               # Documentation
```

## Naming Conventions

### Files
- [Convention, e.g., kebab-case: `user-service.ts`]

### Components
- [Convention, e.g., PascalCase: `UserProfile.tsx`]

### Functions
- [Convention, e.g., camelCase: `getUserById`]

### Constants
- [Convention, e.g., SCREAMING_SNAKE_CASE: `MAX_RETRY_COUNT`]

### Database Tables
- [Convention, e.g., snake_case plural: `user_accounts`]

## Module Organization

### Rules
- Each module is self-contained
- Clear public API via index exports
- No circular dependencies
- Maximum module depth: [N] levels

### Module Structure
```text
feature/
├── index.ts        # Public API exports
├── types.ts        # Type definitions
├── service.ts      # Business logic
├── repository.ts   # Data access
└── __tests__/      # Tests
```

## External Service Interfaces

<!--
  Document all externally exposed APIs and services.
  This is the contract the system provides to external consumers.
-->

### Service Interface Inventory

| ID | Service/Endpoint | Method | Description | Auth Required | Rate Limit |
|----|------------------|--------|-------------|---------------|------------|
| API-001 | [/api/v1/resource] | [GET/POST/etc.] | [What it does] | [Yes/No] | [Limit] |
| API-002 | [/api/v1/resource/:id] | [Method] | [Description] | [Auth] | [Limit] |

### REST API Endpoints

#### [Resource Name] API

| Endpoint | Method | Description | Request | Response |
|----------|--------|-------------|---------|----------|
| `/api/v1/[resource]` | GET | List all [resources] | Query params | Array of [Resource] |
| `/api/v1/[resource]/:id` | GET | Get single [resource] | Path param | [Resource] object |
| `/api/v1/[resource]` | POST | Create [resource] | [Resource] body | Created [Resource] |
| `/api/v1/[resource]/:id` | PUT | Update [resource] | [Resource] body | Updated [Resource] |
| `/api/v1/[resource]/:id` | DELETE | Delete [resource] | Path param | Success message |

### WebSocket/Event Interfaces

| Channel/Event | Direction | Description | Payload |
|---------------|-----------|-------------|---------|
| [event.name] | [In/Out/Bidirectional] | [Description] | [Payload structure] |

### External Integrations

| Integration | Type | Purpose | Endpoint/SDK |
|-------------|------|---------|--------------|
| [Service Name] | [REST/gRPC/SDK] | [Why integrated] | [Endpoint or SDK name] |

## API Patterns

### REST Conventions
- `GET /api/[resource]` - List resources
- `GET /api/[resource]/:id` - Get single resource
- `POST /api/[resource]` - Create resource
- `PUT /api/[resource]/:id` - Update resource
- `DELETE /api/[resource]/:id` - Delete resource

### Response Format
```json
{
  "data": {},
  "error": null,
  "meta": {}
}
```

### Error Response Format
```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable message",
    "details": {}
  }
}
```

## Database Conventions

### Tables
- [Naming convention]
- [Primary key convention]

### Migrations
- [Migration file naming]
- [Migration process]

## Documentation

### Locations
- API docs: [location]
- Architecture docs: [location]
- User guides: [location]

### Requirements
- [What must be documented]
- [Documentation format]

