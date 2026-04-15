# Sub-agent design

## When to use a skill vs. an agent

- A **skill** is "trigger + instruction". It activates automatically based on
  its `description` and runs inside the main Claude session.
- An **agent** is a standalone sub-session with its own context and its own
  set of tools. It is launched via the `Agent` tool.

Rule of thumb: if the task needs its own context, a multi-step process, or
isolation — it is an agent. If a short instruction inside the main session is
enough — it is a skill.

## The "router → agent" pattern

A handy pattern: a lightweight skill with an aggressive `description` catches
the request and immediately delegates to an agent of the same name. This way
activation is reliable, while all the heavy logic lives in the agent, where
it is easier to restrict tools and model.

Example: a lightweight router skill catches the request and delegates to an
agent of the same name.

## When to introduce a new agent

- The same task shows up across several skills in an identical way — extract
  it into an agent.
- You need a separate context / model / toolset.
- The pipeline has 3+ steps with its own memory.

## Things to avoid

- One agent = one area of responsibility. Do not build a "do-everything" god
  agent.
- Do not give the agent more tools than it needs (`tools:` in frontmatter).
- Do not call agents recursively without a clear exit condition.
