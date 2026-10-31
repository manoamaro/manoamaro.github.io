# Repository guidance

## CodeGraph

In repositories indexed by CodeGraph (a `.codegraph/` directory exists at the repo root), reach for it before grep/find or reading files when you need to understand or locate code. Use `codegraph_explore` when available, or `codegraph explore "<symbol names or question>"` in the shell. If there is no `.codegraph/` directory, skip CodeGraph entirely; indexing is the user's decision.

## Site writing style

- Write in Manoel's first-person, conversational voice: direct and curious, as a developer explaining what he learned.
- Introduce a concept in plain language, then work through small concrete examples. Use transitions such as “For example”, “Now”, and “So” naturally, without repeating them mechanically.
- Keep explanations practical and approachable. Define variables, assumptions, and terminology before relying on them; explain why a result follows.
- Use readable Ruby examples where appropriate, and preserve the author's existing terminology and narrative. Correct grammar and technical mistakes without imitating accidental errors or making the prose overly formal.
- Use Markdown headings, short paragraphs, inline code, and Jekyll highlight blocks consistently with existing posts. Cite reliable sources for technical claims.
- Preserve published post URLs and dates. Keep drafts under `_drafts` unless publication is explicitly requested.
