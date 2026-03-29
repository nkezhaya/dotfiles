---
name: phoenix-ecto-native-audit
description: Audits Elixir, Phoenix, and Ecto code for low-level or custom logic that should use public framework APIs instead. Use when reviewing changesets, forms, validations, naming, routing, or recent edits for idiomatic Phoenix/Ecto-native replacements such as changed?/2, get_field/3, get_assoc/3, Phoenix.Naming.humanize/1, to_form/2, and inputs_for.
---

# Phoenix / Ecto Native Audit

Audit code for places where framework-native APIs should replace lower-level, manual, or custom logic.

Be aggressive about *looking* for these cases, but conservative about *reporting* them. Report only when the replacement is a real improvement and preserves semantics.

## Priority Order

Prefer reuse in this order:
1. Existing project helpers and patterns already used in the repo
2. Elixir or Erlang standard library
3. Ecto or Phoenix public APIs
4. Installed dependencies

## Core Principle

Treat direct access to framework internals as suspicious when a public helper likely exists.

Examples:
- accessing `changeset.changes` or `changeset.data` directly instead of `changed?/2`, `fetch_change/2`, `get_change/3`, `get_field/3` for plain fields, or `get_assoc/3` for associations
- manually formatting labels or names instead of `Phoenix.Naming.humanize/1`
- manual nested form plumbing instead of `to_form/2`, `Phoenix.Component.form/1`, and `inputs_for`
- manual relation or changeset inspection that bypasses Ecto relation-aware helpers
- branching or wrapper helpers around public Phoenix/Ecto APIs that already handle nil, empty, or unloaded values safely, such as `Repo.preload/2`

Do not recommend churn for its own sake. The replacement must be clearer, more idiomatic, and semantically honest.

## Audit Workflow

1. Read `mix.exs` first.
   - Confirm Phoenix/Ecto are present.
   - Note any relevant dependencies that may already provide a better capability.

2. Determine scope.
   - If the user names files or functions, audit those first.
   - If the user refers to recent work, inspect git status/diff to find touched files.
   - If scope is unclear, prefer recently changed Elixir, HEEx, and LiveView files.

3. Search aggressively for suspicious patterns, especially in changed files.

4. For each candidate, ask:
   - Is a public Phoenix/Ecto/project API being bypassed?
   - Does the existing API actually cover the same semantics?
   - Would the replacement make the code more idiomatic and easier to maintain?
   - Is the replacement already used elsewhere in the repo?

5. Organize findings into:
   - `High-confidence replacements`
   - `Possible replacements`
   - `Keep as-is`

## High-Suspicion Patterns

Look especially for these:

### Ecto changesets
- `Map.has_key?(changeset.changes, field)`
- `Map.get(changeset.changes, field)`
- direct reads of `changeset.changes`, `changeset.data`, or relation internals
- custom change-detection helpers that duplicate `changed?/2`, `fetch_change/2`, `get_change/3`, or `fetch_field/2`
- manual relation inspection where `get_assoc/3` would be clearer
- `get_field(changeset, :some_assoc)` on associations instead of `get_assoc/2` or `get_assoc/3`
- parent changesets peeking into child fields like `value.name` when the child changeset should own validity
- custom wrappers around obvious Ecto validations or constraints

### Phoenix / LiveView forms and templates
- `Phoenix.HTML.form_for`
- passing a changeset directly to `<.form>` instead of using `to_form/2`
- `<.form let={f}>` when direct `@form[:field]` access is the idiomatic pattern
- manual nested form indexing or loops where `inputs_for` should be used
- raw HTML string assertions in LiveView tests instead of DOM-based assertions
- manual branching before `Repo.preload/2` or similar public APIs when the API already accepts the current shape safely

### Phoenix helpers and naming
- manual humanization or label formatting that should use `Phoenix.Naming.humanize/1`
- custom path, URL, or route naming logic that duplicates project or Phoenix helpers
- custom wrappers around Phoenix helpers that add no real domain meaning

### General Elixir / stdlib duplication
- manual string, enum, map, URI, date, or list operations where stdlib already has a direct helper
- helper functions that only rename an obvious primitive without adding domain meaning

## Strong Candidate Replacements

When semantics line up, strongly prefer these kinds of replacements:
- `Ecto.Changeset.changed?/2`
- `Ecto.Changeset.fetch_change/2`
- `Ecto.Changeset.get_change/3`
- `Ecto.Changeset.get_field/3` for plain fields, not associations
- `Ecto.Changeset.get_assoc/2` or `Ecto.Changeset.get_assoc/3` for associations
- `Ecto.Changeset.fetch_field/2`
- `Ecto.Changeset.validate_required/3`
- `Ecto.Changeset.unique_constraint/3`
- `Ecto.Changeset.assoc_constraint/2`
- `Phoenix.Naming.humanize/1`
- `Phoenix.Component.to_form/2`
- `Phoenix.Component.form/1`
- `Phoenix.Component.inputs_for/1`
- direct `Repo.preload/2` when the current input shape is already one the API safely accepts

Also check whether the repo already has a preferred helper that should be used instead of the framework primitive.

## Association Retrieval Rule

For associations, do not use or recommend `get_field(changeset, :some_assoc)`.

Instead:
- use `get_assoc(changeset, :some_assoc, :struct)` when the caller explicitly needs associated structs
- use `get_assoc(changeset, :some_assoc)` when the caller wants association changesets, or when either representation would work
- if it does not matter, prefer `get_assoc(changeset, :some_assoc)` because it is shorter and keeps the code relation-aware

Treat `get_field/3` on associations as a high-confidence replacement opportunity unless the code is intentionally working with a non-association field of the same name.

## What Not to Report

Do not report:
- replacements that subtly change semantics
- cases where the lower-level code is actually clearer
- project-specific abstractions that genuinely add domain meaning
- speculative replacements you cannot justify from Phoenix/Ecto/public APIs or repo precedent

## Output Format

Use this format:

### High-confidence replacements
- `path:line` — current helper or logic
  - Replace with: existing capability
  - Why: short concrete reason

### Possible replacements
- `path:line` — current helper or logic
  - Replace with: existing capability
  - Caveat: what needs review

### Keep as-is
- `path:line` — current helper or logic
  - Existing capability: what looked relevant
  - Why keep it: short concrete reason

## Review Standard

The goal is not merely shorter code. The goal is code an experienced Phoenix/Ecto maintainer would naturally write by reaching for the public API first, instead of reconstructing framework behavior from lower-level pieces.
