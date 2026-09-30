#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
# Render a unified diff as GitHub-style standalone HTML (default) or markdown,
# for the DSH sidebar.
import argparse
import html
import re
import sys

STYLE_BLOCK = """<style>
.dfd{border:1px solid #d0d7de;border-radius:6px;overflow-x:auto;overflow-y:hidden;width:max-content;max-width:100%;font-size:12px;line-height:20px;color:#24292f;margin:12px 0;font-family:ui-monospace,SFMono-Regular,'SF Mono',Menlo,Consolas,'Liberation Mono',monospace!important}
.dfh{display:flex;justify-content:space-between;align-items:center;background-color:#f6f8fa;padding:8px 16px;border-bottom:1px solid #d0d7de;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI','PingFang SC',sans-serif;font-size:12px}
.dft{border-collapse:collapse;border-spacing:0;background:#fff;font-family:ui-monospace,SFMono-Regular,'SF Mono',Menlo,Consolas,'Liberation Mono',monospace!important}
.dfn{padding:0 10px;color:#6e7781;background-color:#f6f8fa;text-align:right;user-select:none;vertical-align:middle;font-family:ui-monospace,SFMono-Regular,'SF Mono',Menlo,Consolas,'Liberation Mono',monospace!important}
.dfc{padding:0 16px;white-space:pre;vertical-align:middle;font-family:ui-monospace,SFMono-Regular,'SF Mono',Menlo,Consolas,'Liberation Mono',monospace!important}
.tr-a{background-color:#e6ffec}
.tr-d{background-color:#ffeef0}
.tr-h{background-color:#f1f8ff}
.sp-a{color:#1a7f37}
.sp-d{color:#cb2431}
.sp-h{color:#0550ae}
.sp-m{color:#6e7781}
.sp-c{color:#57606a}
/* Wrap mode (off by default): the in-page Wrap button toggles the body class
   "wrap"; --wrap renders that class on from the start. */
body.wrap .dfd{width:auto;max-width:100%;overflow-x:hidden;overflow-y:visible}
body.wrap .dft{table-layout:fixed;width:100%}
body.wrap .dfc{white-space:pre-wrap;overflow-wrap:anywhere}
body.wrap .dfn,body.wrap .dfc{vertical-align:top}
/* Wrap toggle: pinned to the viewport so it stays reachable while scrolling. */
.vt{position:fixed;top:8px;right:12px;z-index:20;padding:6px 10px;font:600 12px/1 -apple-system,BlinkMacSystemFont,'Segoe UI','PingFang SC',sans-serif;color:#24292f;background:#f6f8fa;border:1px solid #d0d7de;border-radius:6px;cursor:pointer;box-shadow:0 1px 3px rgba(27,31,36,.12)}
.vt:hover{background:#eef1f4}
.vt:active{background:#e6eaef}
</style>"""

HTML_EXTRA_STYLE = """<style>
body{margin:16px;background:#fff;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI','PingFang SC',sans-serif}
h1{font-size:18px;font-weight:600;color:#24292f;margin:0 0 12px}
/* GitHub-style sticky file header: each <summary> pins to the top while its own
   <details> block is in view, then gets pushed off by the next file's summary.
   Sticky needs every ancestor to be overflow:visible (see `details` below). */
summary{position:sticky;top:0;z-index:2;cursor:pointer;margin:16px 0 4px;padding:6px 12px;font-size:13px;font-weight:600;font-family:ui-monospace,SFMono-Regular,'SF Mono',Menlo,Consolas,'Liberation Mono',monospace;background:#f6f8fa;border:1px solid #d0d7de;border-radius:6px}
details{overflow:visible}
</style>"""

HUNK_RE = re.compile(r'^@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@(.*)$')

# In-page wrap switch. Toggles a body class only; no storage APIs are used because
# sidebar document iframes are sandboxed without allow-same-origin (localStorage
# throws there), and `w` gives a keyboard shortcut.
TOGGLE_BUTTON = '<button id="wrap-toggle" class="vt" type="button" aria-pressed="false">Wrap: off</button>'

TOGGLE_SCRIPT = """<script>
(function () {
  var body = document.body;
  var button = document.getElementById('wrap-toggle');
  if (!button) return;
  function sync() {
    var on = body.classList.contains('wrap');
    button.textContent = 'Wrap: ' + (on ? 'on' : 'off');
    button.setAttribute('aria-pressed', on ? 'true' : 'false');
  }
  button.addEventListener('click', function () {
    body.classList.toggle('wrap');
    sync();
  });
  document.addEventListener('keydown', function (event) {
    if (event.key !== 'w' && event.key !== 'W') return;
    if (event.metaKey || event.ctrlKey || event.altKey) return;
    body.classList.toggle('wrap');
    sync();
  });
  sync();
})();
</script>"""


def esc(text, pipe_safe=False):
    out = html.escape(text, quote=False)
    # markdown pipes inside <td> break table structure; swap them for a box glyph.
    return out.replace('|', '\u2502') if pipe_safe else out


def stat_spans(added, removed):
    return ('<span class="sp-a" style="font-weight:600">+{}</span> '
            '<span class="sp-d" style="font-weight:600">\u2212{}</span>').format(added, removed)


class FileBlock:
    def __init__(self, path):
        self.path = path
        self.added = 0
        self.removed = 0
        self.rows = []
        self.binary = False
        self.old_path = None
        self.new_path = None

    @property
    def display_path(self):
        if self.old_path and self.new_path and self.old_path != self.new_path:
            return '{} \u2192 {}'.format(self.old_path, self.new_path)
        return self.path


def num_cell(no):
    return '<td class="dfn">{}</td>'.format(esc(str(no)) if no is not None else '')


def code_cell(spans):
    return '<td class="dfc">{}</td>'.format(''.join(spans))


def parse(diff_text):
    files = []
    cur = None
    in_hunk = False
    old_no = new_no = 0
    for line in diff_text.splitlines():
        if line.startswith('diff --git '):
            path = line[len('diff --git '):].split(' b/')[-1]
            cur = FileBlock(path)
            files.append(cur)
            in_hunk = False
        elif cur is None:
            continue
        elif line.startswith('@@') and HUNK_RE.match(line):
            m = HUNK_RE.match(line)
            old_no = int(m.group(1))
            new_no = int(m.group(3))
            cur.rows.append((None, None, 'hunk', line))
            in_hunk = True
        elif line.startswith('Binary files') or line.startswith('GIT binary patch'):
            cur.binary = True
        elif not in_hunk:
            if line.startswith('--- '):
                cur.old_path = re.sub(r'^a/', '', line[4:].strip())
            elif line.startswith('+++ '):
                cur.new_path = re.sub(r'^b/', '', line[4:].strip())
        elif line.startswith('+'):
            cur.rows.append((None, new_no, 'add', line[1:]))
            new_no += 1
            cur.added += 1
        elif line.startswith('-'):
            old_no += 1
            cur.rows.append((old_no, None, 'del', line[1:]))
            cur.removed += 1
        elif line.startswith('\\'):
            cur.rows.append((None, None, 'meta', line))
        else:
            cur.rows.append((old_no, new_no, 'ctx', line[1:]))
            old_no += 1
            new_no += 1
    return files


def render_row(old_no, new_no, kind, text, pipe_safe=False):
    if kind == 'hunk':
        row_cls = ' class="tr-h"'
        code = '<span class="sp-h">{}</span>'.format(esc(text, pipe_safe))
    elif kind == 'add':
        row_cls = ' class="tr-a"'
        code = '<span class="sp-a">+</span>' + esc(text, pipe_safe)
    elif kind == 'del':
        row_cls = ' class="tr-d"'
        code = '<span class="sp-d">-</span>' + esc(text, pipe_safe)
    elif kind == 'meta':
        row_cls = ''
        code = '<span class="sp-m">{}</span>'.format(esc(text, pipe_safe))
    else:
        row_cls = ''
        code = '<span class="sp-c">&#160;</span>' + esc(text, pipe_safe)
    return '<tr{}>{}{}{}</tr>'.format(row_cls, num_cell(old_no), num_cell(new_no), code_cell(code))


def render_file(block, pipe_safe=False, show_header=True):
    body_rows = []
    if block.binary:
        body_rows.append(render_row(None, None, 'meta', 'Binary file not shown', pipe_safe))
    for old_no, new_no, kind, text in block.rows:
        body_rows.append(render_row(old_no, new_no, kind, text, pipe_safe))
    header = ''
    if show_header:
        header = (
            '<div class="dfh">'
            '<span><b>{title}</b></span>'
            '<span>{stats}</span>'
            '</div>'
        ).format(title=esc(block.display_path, pipe_safe), stats=stat_spans(block.added, block.removed))
    table = (
        '<table class="dft">'
        '<colgroup><col style="width:1%"><col style="width:1%"><col></colgroup>'
        '<tbody>{rows}</tbody></table>'
    ).format(rows=''.join(body_rows))
    return '<div class="dfd">{header}{table}</div>'.format(header=header, table=table)


def render_markdown(files, title):
    total_added = sum(f.added for f in files)
    total_removed = sum(f.removed for f in files)
    parts = ['# {}{}'.format(esc(title), ' ' + stat_spans(total_added, total_removed)), '', STYLE_BLOCK, '']
    parts.extend(render_file(f, pipe_safe=True) for f in files)
    parts.append('')
    return '\n'.join(parts)


def render_html(files, title, wrap=False):
    total_added = sum(f.added for f in files)
    total_removed = sum(f.removed for f in files)
    parts = [
        '<!doctype html>',
        '<html lang="en">',
        '<head>',
        '<meta charset="utf-8">',
        '<meta name="viewport" content="width=device-width, initial-scale=1">',
        '<title>{}</title>'.format(esc(title)),
        STYLE_BLOCK,
        HTML_EXTRA_STYLE,
        '</head>',
        '<body class="wrap">' if wrap else '<body>',
        '<h1>{}{}</h1>'.format(esc(title), ' ' + stat_spans(total_added, total_removed)),
    ]
    for block in files:
        parts.append('<details open><summary>{}&nbsp;&nbsp;{}</summary>{}</details>'.format(
            esc(block.display_path), stat_spans(block.added, block.removed),
            render_file(block, show_header=False)))
    parts.extend([TOGGLE_BUTTON, TOGGLE_SCRIPT, '</body>', '</html>', ''])
    return '\n'.join(parts)


def main():
    ap = argparse.ArgumentParser(description='Render a unified diff as standalone HTML (default) or markdown')
    ap.add_argument('input', help="diff file path, or '-' for stdin")
    ap.add_argument('-o', '--output', help='output path; the extension picks the format (.html or .md)')
    ap.add_argument('--title', default='Diff', help='top-level heading')
    ap.add_argument('--format',
                    choices=('auto', 'html', 'md'),
                    default='auto',
                    help="output format; 'auto' infers it from the -o extension (default: html)")
    ap.add_argument('--wrap',
                    action='store_true',
                    help='start with long lines wrapped; default is no wrapping '
                         '(the page also has a Wrap button and a `w` shortcut)')
    args = ap.parse_args()
    if args.input == '-':
        diff_text = sys.stdin.read()
    else:
        with open(args.input, encoding='utf-8', errors='replace') as f:
            diff_text = f.read()

    fmt = args.format
    if fmt == 'auto':
        fmt = 'md' if (args.output and args.output.lower().endswith(('.md', '.markdown'))) else 'html'

    out_path = args.output
    if not out_path:
        if args.input == '-':
            ap.error('-o/--output is required when reading from stdin')
        base = re.sub(r'\.(diff|patch)$', '', args.input) or 'diff'
        out_path = base + ('.md' if fmt == 'md' else '.html')

    files = parse(diff_text)
    if not files:
        ap.error('no "diff --git" sections found in input')
    if args.wrap and fmt == 'md':
        print('warning: --wrap applies to HTML output only; markdown output is unchanged',
              file=sys.stderr)
    text = (render_markdown(files, args.title) if fmt == 'md'
            else render_html(files, args.title, wrap=args.wrap))
    with open(out_path, 'w', encoding='utf-8') as f:
        f.write(text)
    print(out_path)


if __name__ == '__main__':
    main()
