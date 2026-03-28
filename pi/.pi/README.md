# Pi config layout

This repository mirrors the global Pi config at `~/.pi`.

## Important layout rule

Do **not** place prompts, extensions, skills, or other agent resources directly under `.pi/`.
In this repo, global Pi resources live under `.pi/agent/`.

Use these paths:

- `.pi/agent/settings.json`
- `.pi/agent/prompts/`
- `.pi/agent/extensions/`
- `.pi/agent/skills/`

Do not use these paths:

- `.pi/settings.json`
- `.pi/prompts/`
- `.pi/extensions/`
- `.pi/skills/`

## Why

Pi's **global** config layout uses `~/.pi/agent/...`.
Flattened `.pi/...` paths are for **project-local** Pi config, not this repo.

## Instructions for coding agents

Before creating or editing Pi resources in this repo, assume this is a mirror of `~/.pi`, not a project-local `.pi` directory.

Therefore:

- prompts go in `.pi/agent/prompts/`
- extensions go in `.pi/agent/extensions/`
- skills go in `.pi/agent/skills/`
- settings go in `.pi/agent/settings.json`

If unsure, prefer `.pi/agent/...` over `.pi/...`.
