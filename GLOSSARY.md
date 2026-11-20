# zdotdir

Personal macOS dotfiles: shell, editor, terminal and the scheduled jobs that run on the workstation.

## Workday apps

**Workday apps**:
The chat and meeting apps that are open only during working hours: Slack and Microsoft Teams every weekday, plus Roar on Fridays.
_Avoid_: PGD apps, work apps

**Open run**:
The weekday 07:00 job that starts the workday apps.
_Avoid_: open task, launch job

**Close run**:
The weekday 17:00 job that quits Slack and Teams after a warning dialog.
_Avoid_: close task, quit job

**Catch-up run**:
An open or close run that happens on wake because the Mac was asleep at the scheduled time. It runs only if it is still inside its time window.
_Avoid_: missed run, late run

**Snooze**:
Putting off a close run by 10 minutes from its warning dialog.
_Avoid_: postpone, delay

**Paused date**:
A calendar day, such as a holiday or a PTO day, on which neither the open run nor the close run happens.
_Avoid_: holiday mode, vacation, pause range
