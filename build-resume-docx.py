#!/usr/bin/env python3
"""
Build the Word resume from the website's markdown source.

Single source of truth:  frontend/src/content/resume.md
Output:                  Fred-Jabbari-Resume.docx  (repo root)

Standard library only -- a .docx is a zip of OOXML parts, so no python-docx
required. This matters because the existing sync-resume-md-to-docx.py pip-installs
python-docx and hardcodes a macOS path that does not exist on this machine.

Run:
  C:\\Users\\p3383510\\tools\\python312\\python.exe build-resume-docx.py
"""

import re
import zipfile
from pathlib import Path
from xml.sax.saxutils import escape

REPO = Path(__file__).resolve().parent
MD = REPO / "frontend" / "src" / "content" / "resume.md"
OUT = REPO / "Fred-Jabbari-Resume.docx"

NAVY = "1F3864"
SLATE = "44546A"
BODY = "262626"
LINK = "0563C1"
FONT = "Calibri"
RIGHT_TAB = 10440          # 12240 page - 2*900 margins

body_xml = []
rels = []                  # external hyperlink relationships
_rid = [1]


def esc(t):
    return escape(str(t))


def next_rid():
    _rid[0] += 1
    return f"rId{_rid[0]}"


def rpr(bold=False, italic=False, size=19, color=BODY, caps=False, underline=False):
    parts = [f'<w:rFonts w:ascii="{FONT}" w:hAnsi="{FONT}" w:cs="{FONT}"/>']
    if bold:
        parts.append("<w:b/>")
    if italic:
        parts.append("<w:i/>")
    if caps:
        parts.append("<w:caps/>")
    if underline:
        parts.append('<w:u w:val="single"/>')
    parts.append(f'<w:color w:val="{color}"/>')
    parts.append(f'<w:sz w:val="{size}"/><w:szCs w:val="{size}"/>')
    return "<w:rPr>" + "".join(parts) + "</w:rPr>"


def run(text, **kw):
    return f'<w:r>{rpr(**kw)}<w:t xml:space="preserve">{esc(text)}</w:t></w:r>'


def hyperlink(url, text, size=19):
    rid = next_rid()
    rels.append(
        f'<Relationship Id="{rid}" '
        'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink" '
        f'Target="{esc(url)}" TargetMode="External"/>'
    )
    return (
        f'<w:hyperlink r:id="{rid}">'
        f'<w:r>{rpr(color=LINK, underline=True, size=size)}'
        f'<w:t xml:space="preserve">{esc(text)}</w:t></w:r></w:hyperlink>'
    )


LINK_RE = re.compile(r"\[([^\]]+)\]\(([^)]+)\)")
BOLD_RE = re.compile(r"\*\*([^*]+)\*\*")
ITAL_RE = re.compile(r"(?<!\*)\*([^*]+)\*(?!\*)")


def inline(text, size=19, base_bold=False, base_italic=False, color=BODY):
    """Render markdown links, **bold** and *italic* into runs."""
    out = []
    pos = 0
    for m in LINK_RE.finditer(text):
        if m.start() > pos:
            out.append(_emphasis(text[pos:m.start()], size, base_bold, base_italic, color))
        label, url = m.group(1), m.group(2)
        # A bare-URL label reads badly in print; shorten it.
        if label.startswith("http"):
            label = label.replace("https://", "").replace("http://", "").rstrip("/")
        out.append(hyperlink(url, label, size))
        pos = m.end()
    if pos < len(text):
        out.append(_emphasis(text[pos:], size, base_bold, base_italic, color))
    return "".join(out)


def _emphasis(text, size, base_bold, base_italic, color):
    out = []
    pos = 0
    for m in BOLD_RE.finditer(text):
        if m.start() > pos:
            out.append(_italics(text[pos:m.start()], size, base_bold, base_italic, color))
        out.append(run(m.group(1), bold=True, italic=base_italic, size=size, color=color))
        pos = m.end()
    if pos < len(text):
        out.append(_italics(text[pos:], size, base_bold, base_italic, color))
    return "".join(out)


def _italics(text, size, base_bold, base_italic, color):
    out = []
    pos = 0
    for m in ITAL_RE.finditer(text):
        if m.start() > pos:
            out.append(run(text[pos:m.start()], bold=base_bold, italic=base_italic,
                           size=size, color=color))
        out.append(run(m.group(1), bold=base_bold, italic=True, size=size, color=color))
        pos = m.end()
    if pos < len(text):
        out.append(run(text[pos:], bold=base_bold, italic=base_italic, size=size, color=color))
    return "".join(out)


def para(runs, align=None, before=0, after=40, indent=None, hanging=None,
         border=False, tabs=False):
    p = ["<w:pPr>"]
    if align:
        p.append(f'<w:jc w:val="{align}"/>')
    if tabs:
        p.append(f'<w:tabs><w:tab w:val="right" w:pos="{RIGHT_TAB}"/></w:tabs>')
    if indent is not None or hanging is not None:
        i = "<w:ind"
        if indent is not None:
            i += f' w:left="{indent}"'
        if hanging is not None:
            i += f' w:hanging="{hanging}"'
        p.append(i + "/>")
    if border:
        p.append('<w:pBdr><w:bottom w:val="single" w:sz="8" w:space="2" '
                 f'w:color="{NAVY}"/></w:pBdr>')
    p.append(f'<w:spacing w:before="{before}" w:after="{after}" '
             'w:line="252" w:lineRule="auto"/>')
    p.append("</w:pPr>")
    body_xml.append("<w:p>" + "".join(p) + "".join(runs) + "</w:p>")


# ── parse the markdown ─────────────────────────────────────────────────────

lines = MD.read_text(encoding="utf-8").splitlines()
i = 0
seen_h1 = False

while i < len(lines):
    raw = lines[i]
    line = raw.strip()
    i += 1

    if not line or line == "---":
        continue

    # H1 -> name block
    if line.startswith("# "):
        para([run(line[2:], bold=True, size=40, color=NAVY)], align="center", after=30)
        seen_h1 = True
        continue

    # H2 -> section heading with rule
    if line.startswith("## "):
        para([run(line[3:], bold=True, size=22, color=NAVY, caps=True)],
             before=200, after=80, border=True)
        continue

    # H3 -> company / role heading
    if line.startswith("### "):
        para([inline(line[4:], size=20)], before=150, after=0)
        continue

    # bullets
    if line.startswith("- ") or line.startswith("* "):
        depth = (len(raw) - len(raw.lstrip())) // 2
        marker = "\u25aa  " if depth == 0 else "\u2013  "
        para([run(marker, size=19, color=NAVY), inline(line[2:])],
             indent=200 + depth * 200, hanging=200, after=30)
        continue

    # the contact line and the title line directly under the name
    if seen_h1 and line.startswith("**") and line.endswith("**") and "|" not in line:
        inner = line[2:-2]
        # role line with a date range separated by |
        para([inline(inner, size=19, color=SLATE)], align="center", after=30)
        continue

    # role + dates:  **Title** | Dates
    if line.startswith("**") and "|" in line:
        title, _, dates = line.partition("|")
        para([inline(title.strip().strip("*"), size=19, base_italic=True, color=SLATE),
              "<w:r><w:tab/></w:r>",
              run(dates.strip(), bold=True, size=19, color=SLATE)],
             tabs=True, after=60)
        continue

    # bold-only line -> sub-heading inside a role
    if line.startswith("**") and line.endswith("**"):
        para([run(line[2:-2], bold=True, italic=True, size=19, color=NAVY)],
             before=100, after=40)
        continue

    # italic-only line -> the "Technologies across these roles" note
    if line.startswith("*") and line.endswith("*"):
        para([inline(line, size=18, color=SLATE)], after=50)
        continue

    # everything else: body paragraph. Centre the two lines under the name.
    centred = seen_h1 and len(body_xml) <= 3
    para([inline(line)], align="center" if centred else None,
         after=30 if centred else 60)


# ── package ────────────────────────────────────────────────────────────────

DOC = (
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n'
    '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" '
    'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
    "<w:body>" + "".join(body_xml) +
    '<w:sectPr><w:pgSz w:w="12240" w:h="15840"/>'
    '<w:pgMar w:top="720" w:right="900" w:bottom="720" w:left="900" '
    'w:header="0" w:footer="0" w:gutter="0"/></w:sectPr>'
    "</w:body></w:document>"
)

CONTENT_TYPES = (
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n'
    '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
    '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
    '<Default Extension="xml" ContentType="application/xml"/>'
    '<Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>'
    '<Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>'
    '<Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>'
    "</Types>"
)

RELS = (
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n'
    '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
    '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>'
    '<Relationship Id="rIdCore" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>'
    "</Relationships>"
)

DOC_RELS = (
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n'
    '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
    '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>'
    + "".join(rels) +
    "</Relationships>"
)

STYLES = (
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n'
    '<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">'
    "<w:docDefaults><w:rPrDefault><w:rPr>"
    f'<w:rFonts w:ascii="{FONT}" w:hAnsi="{FONT}" w:cs="{FONT}"/>'
    f'<w:color w:val="{BODY}"/><w:sz w:val="19"/><w:szCs w:val="19"/>'
    "</w:rPr></w:rPrDefault><w:pPrDefault><w:pPr>"
    '<w:spacing w:after="40" w:line="252" w:lineRule="auto"/>'
    "</w:pPr></w:pPrDefault></w:docDefaults>"
    '<w:style w:type="paragraph" w:default="1" w:styleId="Normal">'
    '<w:name w:val="Normal"/><w:qFormat/></w:style>'
    "</w:styles>"
)

CORE = (
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n'
    '<cp:coreProperties '
    'xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" '
    'xmlns:dc="http://purl.org/dc/elements/1.1/">'
    "<dc:title>Fred Jabbari - Resume</dc:title>"
    "<dc:creator>Fred Jabbari</dc:creator>"
    "<cp:lastModifiedBy>Fred Jabbari</cp:lastModifiedBy>"
    "</cp:coreProperties>"
)

with zipfile.ZipFile(OUT, "w", zipfile.ZIP_DEFLATED) as z:
    z.writestr("[Content_Types].xml", CONTENT_TYPES)
    z.writestr("_rels/.rels", RELS)
    z.writestr("word/document.xml", DOC)
    z.writestr("word/_rels/document.xml.rels", DOC_RELS)
    z.writestr("word/styles.xml", STYLES)
    z.writestr("docProps/core.xml", CORE)

(REPO / ".docx-build-report.txt").write_text(
    f"output={OUT}\nexists={OUT.exists()}\nbytes={OUT.stat().st_size}\n"
    f"paragraphs={len(body_xml)}\nhyperlinks={len(rels)}\nsource={MD}\n",
    encoding="utf-8",
)
print(f"wrote {OUT} ({OUT.stat().st_size} bytes, {len(body_xml)} paragraphs, "
      f"{len(rels)} hyperlinks)")
