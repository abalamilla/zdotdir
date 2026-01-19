# Fetch My Pending Jira Tickets

Execute `~/.claude/scripts/fetch-my-jira-tickets.sh` and format the output
according to the guidelines below.

## Meta Instructions

**Continuous Improvement:**

- After successfully fetching tickets, analyze the process for potential
  improvements
- If you encounter issues or discover better approaches, UPDATE THIS
  INSTRUCTIONS FILE
- Document what worked well and what didn't to improve future executions

## Implementation

**Script Location:** `~/.claude/scripts/fetch-my-jira-tickets.sh`

**Authentication:**

- Uses environment variables: `JIRA_URL`, `JIRA_API_TOKEN`, and `LLID_FQDA`
- Read-only GET request only

**Query Details:**

- Filters by: Product Domain = Architecture
- User: `$LLID_FQDA` (assignee OR Engineer #2)
- Statuses: Prototype, Prototype Review, In Progress, Needs QR

## Status Mapping

Sprint board columns map to Jira statuses as follows:

- **Prototype** → Jira status "Prototype"
- **Code Review** → Jira status "Prototype Review"
- **Pair** → Jira status "In Progress"
- **Demo** → Jira status "Needs QR"

## Output Requirements

Display pending tickets grouped by status with a brief summary of what's needed
for each ticket.

**Output Format:**

```markdown
# My Pending Tickets - {YYYY-MM-DD}

## Summary

{X} pending ticket(s) found

## Prototype ({count} tickets)

### {TICKET-KEY}: {Summary}

{1-2 sentence summary of what's needed to move this ticket forward}

## Prototype Review ({count} tickets)

### {TICKET-KEY}: {Summary}

{1-2 sentence summary of what's needed to move this ticket forward}

## In Progress (Pair) ({count} tickets)

### {TICKET-KEY}: {Summary}

{1-2 sentence summary of what's needed to move this ticket forward}

## Needs QR (Demo) ({count} tickets)

### {TICKET-KEY}: {Summary}

{1-2 sentence summary of what's needed to move this ticket forward}
```

## Display Guidelines

1. **Grouping:** Group tickets by status in this order: Prototype, Prototype
   Review, In Progress, Needs QR
2. **Format:** Use heading level 2 (##) for status groups, heading level 3 (###)
   for each ticket
3. **Information:** For each ticket show:
   - Ticket key and summary
   - Brief 1-2 sentence summary of what's needed based on the description and
     current status
4. **Summary Content:** Focus on:
   - What action is needed to progress the ticket
   - Any blockers or dependencies mentioned in the description
   - Next steps based on the current status
5. **Clarity:** Keep summaries concise and actionable
6. **Empty Groups:** If a status has no tickets, omit that section entirely

## Validation Checklist

Before displaying output, verify:

- [ ] All tickets have `$LLID_FQDA` as assignee OR Engineer #2
- [ ] All tickets are from Architecture Product Domain
- [ ] All tickets have status: "Prototype", "Prototype Review", "In Progress",
      or "Needs QR"
- [ ] Tickets are grouped by status in the correct order
- [ ] Each ticket has a 1-2 sentence summary of what's needed
- [ ] Empty status groups are omitted from the output

## Troubleshooting

**Common Issues:**

1. **Script Execution Fails**
   - Verify environment variables are set:
     - `echo $JIRA_URL`
     - `echo ${#JIRA_API_TOKEN}`
     - `echo $LLID_FQDA`
   - Ensure script is executable:
     `chmod +x ~/.claude/scripts/fetch-my-jira-tickets.sh`

2. **Authentication Errors**
   - Verify JIRA_API_TOKEN is a valid Personal Access Token (PAT)
   - Ensure token has read permissions for the Architecture project

3. **Empty or Unexpected Results**
   - Check if you have any tickets matching the status filters
   - Verify the exact status names haven't changed in your Jira instance
   - Status names are case-sensitive and must match exactly

4. **User Identification Issues**
   - Ensure `LLID_FQDA` is set to your fully qualified email address
   - Verify the format matches your Jira user identifier

**Note:** Implementation details (URL handling, JQL query syntax) are now
handled by the script at `~/.claude/scripts/fetch-my-jira-tickets.sh`
