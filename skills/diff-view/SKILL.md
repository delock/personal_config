---
name: diff-view
description: Use when showing a diff or patch to the user, or when rendering diff/patch output in the sidebar. Triggers on keywords like diff, patch, git show, git diff, review rendering, and standalone HTML diff view. Renders unified diffs as GitHub-style standalone HTML with the bundled mdiff.py.
---

# diff-view: GitHub-style diff rendering in the sidebar

## Output format: standalone HTML (NOT markdown)

The sidebar's markdown renderer has limitations:
- Inline HTML tables work but CSS `<style>` blocks inside markdown are unreliable
- Large diffs (>500KB of markdown) fail to render entirely
- `|` pipes inside `<td>` break table structure even with `&#124;` entities

**Use standalone HTML files** (`.html` extension) instead. The sidebar opens
them in a webview where CSS works natively.

## Key features of the HTML format:
1. `<details>/<summary>` for per-file collapsible sections
2. CSS classes for red/green row highlighting (`.tr-a` / `.tr-d`)
3. Dual line numbers (old + new)
4. `<style>` block works reliably in standalone HTML
5. GitHub-style sticky file header: each `<summary>` pins to the top while its
   own file block is in view, then is pushed off by the next file's header.
   Requires every ancestor of `<summary>` to stay `overflow:visible`.
6. Typical size: ~300-400KB for a 2000-line diff (vs 1.7MB markdown)

## Line wrapping (off by default)

- Default is **no wrapping**: code cells use `white-space:pre` and the file box
  scrolls horizontally (`overflow-x:auto`), so long lines are reachable instead
  of being clipped.
- The HTML page renders a **Wrap** button fixed to the top-right; clicking it (or
  pressing `w`) toggles `body.wrap`, which switches cells to `white-space:pre-wrap`
  and shrinks the table to the viewport width. The choice applies to the open page
  only — sidebar document iframes are sandboxed without `allow-same-origin`, so no
  storage API is used.
- Pass `--wrap` to render the page already wrapped; the button then toggles it
  back off. The static `class="wrap"` on `body` keeps `--wrap` working even when
  scripts do not run.
- Wrapping is an HTML-only feature; markdown output ignores `--wrap`.

## Generation script location
`mdiff.py` — emits standalone HTML by default. It writes markdown only when the
output path ends in `.md`/`.markdown` or `--format md` is passed (legacy path,
renders flat without colors). `--format html` forces HTML regardless of `-o`.
