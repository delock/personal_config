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

## Generation script location
`mdiff.py` — emits standalone HTML by default. It writes markdown only when the
output path ends in `.md`/`.markdown` or `--format md` is passed (legacy path,
renders flat without colors). `--format html` forces HTML regardless of `-o`.
