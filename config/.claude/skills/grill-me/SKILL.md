---
name: grill-me
description:
  Interview the user relentlessly about a plan or design until reaching shared
  understanding, resolving each branch of the decision tree. Use when user wants
  to stress-test a plan, get grilled on their design, or mentions "grill me".
---

Interview me relentlessly about every aspect of this plan until we reach a
shared understanding. Walk down each branch of the design tree, resolving
dependencies between decisions one-by-one. For each question, provide your
recommended answer.

Ask the questions one at a time.

If a question can be answered by exploring the codebase, explore the codebase
instead.

Once all questions are answered, write a plan to
`docs/plan-<short-topic-slug>.md` in the current repo summarizing every decision
made (as a table or structured list). Do NOT print the plan content in the
terminal — just output the file path as a link and ask the user to review it and
reply with approval before doing any implementation work.
