#!/bin/bash
# Task Manager - Handle time-based reminders and tasks
set -euo pipefail

TASKS_FILE="$HOME/.claude/tasks.json"

# Ensure tasks file exists
if [[ ! -f "$TASKS_FILE" ]]; then
	echo '{"tasks":[],"version":"1.0"}' >"$TASKS_FILE"
fi

# Migrate existing tasks to include type field (default: "user")
migrate_tasks() {
	jq '.tasks |= map(if has("type") then . else . + {"type": "user"} end)' \
		"$TASKS_FILE" >"$TASKS_FILE.tmp"
	mv "$TASKS_FILE.tmp" "$TASKS_FILE"
}

# Run migration on startup
migrate_tasks

# Parse time specification to Unix timestamp
parse_time() {
	local time_spec="$1"
	local now=$(date +%s)

	# Handle "in X minutes/hours"
	if [[ $time_spec =~ ^in[[:space:]]+([0-9]+)[[:space:]]+(minute|minutes|min|mins)$ ]]; then
		local minutes="${BASH_REMATCH[1]}"
		echo $((now + minutes * 60))
		return
	fi

	if [[ $time_spec =~ ^in[[:space:]]+([0-9]+)[[:space:]]+(hour|hours|hr|hrs)$ ]]; then
		local hours="${BASH_REMATCH[1]}"
		echo $((now + hours * 3600))
		return
	fi

	# Handle "at HH:MM" or "at H:MMpm/am"
	if [[ $time_spec =~ ^at[[:space:]]+(.+)$ ]]; then
		local time_part="${BASH_REMATCH[1]}"
		# Try to parse with date command
		local parsed=$(date -j -f "%I:%M%p" "$time_part" "+%s" 2>/dev/null ||
			date -j -f "%H:%M" "$time_part" "+%s" 2>/dev/null ||
			date -j -f "%l:%M%p" "$time_part" "+%s" 2>/dev/null ||
			echo "")

		if [[ -n "$parsed" ]]; then
			# If the time is in the past today, assume tomorrow
			if [[ $parsed -lt $now ]]; then
				parsed=$((parsed + 86400))
			fi
			echo "$parsed"
			return
		fi
	fi

	# Handle "today at HH:MM"
	if [[ $time_spec =~ ^today[[:space:]]+at[[:space:]]+(.+)$ ]]; then
		local time_part="${BASH_REMATCH[1]}"
		local parsed=$(date -j -f "%I:%M%p" "$time_part" "+%s" 2>/dev/null ||
			date -j -f "%H:%M" "$time_part" "+%s" 2>/dev/null ||
			date -j -f "%l:%M%p" "$time_part" "+%s" 2>/dev/null ||
			date -j -f "%I:%M %p" "$time_part" "+%s" 2>/dev/null ||
			echo "")
		if [[ -n "$parsed" ]]; then
			# If the time is in the past today, assume tomorrow
			if [[ $parsed -lt $now ]]; then
				parsed=$((parsed + 86400))
			fi
			echo "$parsed"
			return
		fi
	fi

	# Handle "tomorrow at HH:MM"
	if [[ $time_spec =~ ^tomorrow[[:space:]]+at[[:space:]]+(.+)$ ]]; then
		local time_part="${BASH_REMATCH[1]}"
		local parsed=$(date -j -f "%I:%M%p" "$time_part" "+%s" 2>/dev/null ||
			date -j -f "%H:%M" "$time_part" "+%s" 2>/dev/null ||
			echo "")
		if [[ -n "$parsed" ]]; then
			echo $((parsed + 86400))
			return
		fi
	fi

	# Handle day names (Monday, Tuesday, etc.) with optional "at HH:MM"
	if [[ $time_spec =~ ^(Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday)([[:space:]]+at[[:space:]]+(.+))?$ ]]; then
		local day_name="${BASH_REMATCH[1]}"
		local time_part="${BASH_REMATCH[3]:-09:00am}" # Default to 9:00am if no time specified

		# Get current day of week (0=Sunday, 1=Monday, etc.)
		local current_dow=$(date +%w)
		# Convert day name to number
		local target_dow
		case "$day_name" in
			Sunday) target_dow=0 ;;
			Monday) target_dow=1 ;;
			Tuesday) target_dow=2 ;;
			Wednesday) target_dow=3 ;;
			Thursday) target_dow=4 ;;
			Friday) target_dow=5 ;;
			Saturday) target_dow=6 ;;
		esac

		# Calculate days until target day
		local days_until=$(( (target_dow - current_dow + 7) % 7 ))
		# If the target day is today, schedule for next week
		if [[ $days_until -eq 0 ]]; then
			days_until=7
		fi

		# Parse the time
		local parsed=$(date -j -f "%I:%M%p" "$time_part" "+%s" 2>/dev/null ||
			date -j -f "%H:%M" "$time_part" "+%s" 2>/dev/null ||
			date -j -f "%l:%M%p" "$time_part" "+%s" 2>/dev/null ||
			echo "")

		if [[ -n "$parsed" ]]; then
			echo $((parsed + days_until * 86400))
			return
		fi
	fi

	# Default: parse as absolute time
	date -j -f "%Y-%m-%d %H:%M:%S" "$time_spec" "+%s" 2>/dev/null || echo "$now"
}

# Format timestamp for display
format_time() {
	date -r "$1" "+%I:%M %p on %b %d" 2>/dev/null || echo "unknown time"
}

# Generate unique task ID
generate_id() {
	local max_id=$(jq -r '.tasks | map(.id) | max // 0' "$TASKS_FILE")
	echo $((max_id + 1))
}

# Command: help
cmd_help() {
	cat <<'EOF'
Task Manager - Handle time-based reminders and tasks

USAGE:
  task-manager.sh <command> [arguments]

COMMANDS:
  add <description> <time_spec> [type]  Create a new task (type defaults to "user")
  list [type]                           Show all pending tasks (optionally filter by type)
  complete <task_id>                    Mark a task as completed
  delete <task_id>                      Remove a task
  snooze <task_id> <minutes>            Postpone a task by X minutes
  reschedule <task_id> <time_spec>      Change the due time of an existing task
  help                                  Show this help message

TIME SPECIFICATIONS:
  in X minutes/hours             e.g., "in 30 minutes", "in 2 hours"
  at HH:MM                       e.g., "at 3:00pm", "at 14:30"
  today at HH:MM                 e.g., "today at 3:00pm", "today at 15:00"
  tomorrow at HH:MM              e.g., "tomorrow at 8:00am"
  Monday/Tuesday/etc at HH:MM    e.g., "Monday at 9:00am", "Friday at 2:00pm"

TASK TYPES:
  user                           User-created tasks (default)
  system                         System reminders (e.g., daily check-ins)

EXAMPLES:
  task-manager.sh add "Review PR" "in 30 minutes"
  task-manager.sh add "Team meeting" "tomorrow at 10:00am"
  task-manager.sh add "Daily check-in - 8am" "tomorrow at 8:00am" "system"
  task-manager.sh list           # Show all tasks
  task-manager.sh list user      # Show only user tasks
  task-manager.sh list system    # Show only system tasks
  task-manager.sh complete 1
  task-manager.sh snooze 2 15
  task-manager.sh reschedule 1 "Monday at 9:00am"
  task-manager.sh delete 3
EOF
}

# Command: add
cmd_add() {
	local description="$1"
	local time_spec="$2"
	local task_type="${3:-user}" # Default to "user" if not specified
	local due_time=$(parse_time "$time_spec")
	local task_id=$(generate_id)
	local created_time=$(date +%s)

	# Add task to JSON
	jq --arg id "$task_id" \
		--arg desc "$description" \
		--arg due "$due_time" \
		--arg created "$created_time" \
		--arg type "$task_type" \
		'.tasks += [{
       "id": ($id | tonumber),
       "description": $desc,
       "dueTime": ($due | tonumber),
       "createdTime": ($created | tonumber),
       "status": "pending",
       "type": $type
     }]' "$TASKS_FILE" >"$TASKS_FILE.tmp"

	mv "$TASKS_FILE.tmp" "$TASKS_FILE"

	echo "TASK_ADDED|$task_id|$description|$(format_time "$due_time")"
}

# Command: list
cmd_list() {
	local type_filter="${1:-}" # Optional type filter

	local jq_filter='.tasks[] | select(.status == "pending")'

	# Add type filter if specified
	if [[ -n "$type_filter" ]]; then
		jq_filter="$jq_filter | select(.type == \"$type_filter\")"
	fi

	jq_filter="$jq_filter | \"\\(.id)|\\(.description)|\\(.dueTime)\""

	local tasks=$(jq -r "$jq_filter" "$TASKS_FILE")

	if [[ -z "$tasks" ]]; then
		echo "NO_TASKS"
		return
	fi

	echo "TASK_LIST"
	while IFS='|' read -r id description dueTime; do
		echo "$id|$description|$(format_time "$dueTime")"
	done <<<"$tasks"
}

# Command: complete
cmd_complete() {
	local task_id="$1"

	# Get task description before marking complete
	local description=$(jq -r --arg id "$task_id" \
		'.tasks[] | select(.id == ($id | tonumber)) | .description' "$TASKS_FILE")

	if [[ -z "$description" ]]; then
		echo "TASK_NOT_FOUND|$task_id"
		return 1
	fi

	# Mark as completed
	jq --arg id "$task_id" \
		'(.tasks[] | select(.id == ($id | tonumber)) | .status) = "completed"' \
		"$TASKS_FILE" >"$TASKS_FILE.tmp"

	mv "$TASKS_FILE.tmp" "$TASKS_FILE"

	echo "TASK_COMPLETED|$task_id|$description"
}

# Command: delete
cmd_delete() {
	local task_id="$1"

	# Get task description before deleting
	local description=$(jq -r --arg id "$task_id" \
		'.tasks[] | select(.id == ($id | tonumber)) | .description' "$TASKS_FILE")

	if [[ -z "$description" ]]; then
		echo "TASK_NOT_FOUND|$task_id"
		return 1
	fi

	# Remove task
	jq --arg id "$task_id" \
		'.tasks = [.tasks[] | select(.id != ($id | tonumber))]' \
		"$TASKS_FILE" >"$TASKS_FILE.tmp"

	mv "$TASKS_FILE.tmp" "$TASKS_FILE"

	echo "TASK_DELETED|$task_id|$description"
}

# Command: snooze
cmd_snooze() {
	local task_id="$1"
	local minutes="$2"
	local now=$(date +%s)
	local new_time=$((now + minutes * 60))

	# Get task description
	local description=$(jq -r --arg id "$task_id" \
		'.tasks[] | select(.id == ($id | tonumber)) | .description' "$TASKS_FILE")

	if [[ -z "$description" ]]; then
		echo "TASK_NOT_FOUND|$task_id"
		return 1
	fi

	# Update due time
	jq --arg id "$task_id" --arg newTime "$new_time" \
		'(.tasks[] | select(.id == ($id | tonumber)) | .dueTime) = ($newTime | tonumber)' \
		"$TASKS_FILE" >"$TASKS_FILE.tmp"

	mv "$TASKS_FILE.tmp" "$TASKS_FILE"

	echo "TASK_SNOOZED|$task_id|$description|$(format_time "$new_time")"
}

# Command: reschedule
cmd_reschedule() {
	local task_id="$1"
	local time_spec="$2"
	local new_time=$(parse_time "$time_spec")

	# Get task description
	local description=$(jq -r --arg id "$task_id" \
		'.tasks[] | select(.id == ($id | tonumber)) | .description' "$TASKS_FILE")

	if [[ -z "$description" ]]; then
		echo "TASK_NOT_FOUND|$task_id"
		return 1
	fi

	# Update due time
	jq --arg id "$task_id" --arg newTime "$new_time" \
		'(.tasks[] | select(.id == ($id | tonumber)) | .dueTime) = ($newTime | tonumber)' \
		"$TASKS_FILE" >"$TASKS_FILE.tmp"

	mv "$TASKS_FILE.tmp" "$TASKS_FILE"

	echo "TASK_RESCHEDULED|$task_id|$description|$(format_time "$new_time")"
}

# Main
COMMAND="${1:-}"
shift || true

case "$COMMAND" in
add)
	cmd_add "$1" "$2" "${3:-user}"
	;;
list)
	cmd_list "${1:-}"
	;;
complete)
	cmd_complete "$1"
	;;
delete)
	cmd_delete "$1"
	;;
snooze)
	cmd_snooze "$1" "$2"
	;;
reschedule)
	cmd_reschedule "$1" "$2"
	;;
help | --help | -h | "")
	cmd_help
	;;
*)
	echo "ERROR: Unknown command: $COMMAND" >&2
	echo "" >&2
	cmd_help >&2
	exit 1
	;;
esac
