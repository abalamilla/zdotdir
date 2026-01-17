# Task Management

Manage time-based reminders and tasks. Use `~/.claude/scripts/task-manager.sh`
for all operations.

## Available Operations

Parse the user's request and call the appropriate operation:

### Add Task

User says: "remind me to X at/in TIME" or "add task X at/in TIME"

```bash
~/.claude/scripts/task-manager.sh add "DESCRIPTION" "TIME_SPEC"
```

TIME_SPEC examples: "4pm", "in 10 minutes", "tomorrow at 2pm", "in 2 hours"

### List Tasks

User says: "show my tasks", "list tasks", "what tasks do I have?"

```bash
~/.claude/scripts/task-manager.sh list
```

### Complete Task

User says: "mark task N complete", "complete task N", "done with task N"

```bash
~/.claude/scripts/task-manager.sh complete TASK_ID
```

### Delete Task

User says: "delete task N", "remove task N", "cancel task N"

```bash
~/.claude/scripts/task-manager.sh delete TASK_ID
```

### Snooze Task

User says: "snooze task N for X minutes", "remind me about N in X minutes"

```bash
~/.claude/scripts/task-manager.sh snooze TASK_ID MINUTES
```

## Response Format

After executing the command, provide a brief confirmation with the task details.

**Examples:**

- "✓ Task added: Review PR (due at 4:00 PM)"
- "✓ Task completed: Review PR"
- "✓ Task snoozed: Review PR (now due in 10 minutes)"
- "✓ Task deleted: Review PR"
