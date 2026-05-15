---
paths:
  - "*.{bash,c,clj,cljs,cpp,csh,fish,go,groovy,hcl,java,js,jsx,kcl,kt,lua,pkl,pl,py,rb,rs,sbt,scala,sh,tf,ts,tsx,zsh}"
description: "Development guidelines - load only when editing code"
---

# Development Guidelines

## Core Development Principles

### Design Approach

- **Always use Top Down Design**: Start with high-level behavior and decompose
  into smaller functions
- **Test-Driven Development**: Follow Green, Red, Refactor cycle

### Functional Programming

- Prefer pure functions and immutability
- Minimize side effects and make them explicit
- Use function composition over complex logic

### Code Organization

- Single Responsibility Principle: Each function/module does one thing well
- Prefer editing existing files over creating new ones
- Only create files when absolutely necessary for the goal

## Testing Strategy

**Goal: 100% confidence, not 100% metrics.** Test at the highest abstraction
level that provides confidence.

### Testing Layers (High to Low)

1. **Integration Tests (Primary Focus)**
   - Test complete workflows through public interfaces
   - Validates end-to-end behavior
   - Refactoring resilient: Internal changes don't break tests
   - Use real collaborators when possible

2. **Unit Tests (Selective)**
   - Only for pure functions and complex algorithms
   - Test logic that's difficult to trigger at higher levels

### What NOT to Test

- Simple getters/setters
- Pure dependency injection constructors
- Direct library pass-throughs
- Entry points with no logic (compiler verified)

**Rule of thumb**: If your tests are getting large, the problem is your code,
not your tests. Refactor into smaller functions.

## Architecture Principles

### Non-Determinism

All non-determinism must be behind contracts/interfaces:

- Time and dates (use clock/time interface)
- Random number generation (use RNG interface)
- Network calls (use client interface)
- File system access (use filesystem interface)
- Environment variables (use config interface)

### Entry Points

- Single entry point per application
- No logic in entry points (only dependency injection and forwarding)
- All behavior moved to testable code

### Dependency Injection

- Never use singleton patterns
- Inject dependencies explicitly (no globals)
- Use interfaces for testability

## Code Classification

Every file must be one of these four types:

1. **100% Verified** - Verified by deterministic tests (integration or unit, at
   appropriate abstraction level)
2. **100% Compiler Verified** - Only performs dependency injection (no logic)
3. **Minimal Pass-Through to Library Code** - Direct single invocation, can only
   be implemented one way
4. **Minimal Connector to External Invocation** - Entry point with no logic

## Logging

- Use structured logging (language-appropriate equivalent)
- **Never use singleton loggers** - always inject logger dependency
- Business logic: Log success milestones only, never log errors (return them)
- Entry points: Log errors once at the end when command fails
- Rationale: Avoids duplicate messages, single responsibility, caller control
