#!/usr/bin/env python3
"""Validate the generated .docx: required parts, well-formed XML, resolvable
hyperlink relationships, and a plain-text dump for eyeballing."""

import zipfile
import xml.etree.ElementTree as ET
from pathlib import Path

REPO = Path(__file__).resolve().parent
DOCX = REPO / "Fred-Jabbari-Resume.docx"
OUT = REPO / ".docx-verify.txt"
W = "{http://schemas.openxmlformats.org/wordprocessingml/2006/main}"
R = "{http://schemas.openxmlformats.org/officeDocument/2006/relationships}"

REQUIRED = ["[Content_Types].xml", "_rels/.rels", "word/document.xml",
            "word/_rels/document.xml.rels", "word/styles.xml"]

report, ok = [], True

with zipfile.ZipFile(DOCX) as z:
    names = z.namelist()
    report.append(f"parts: {names}")

    for req in REQUIRED:
        present = req in names
        report.append(f"required {req}: {'OK' if present else 'MISSING'}")
        ok &= present

    for n in names:
        if n.endswith((".xml", ".rels")):
            try:
                ET.fromstring(z.read(n))
                report.append(f"wellformed {n}: OK")
            except ET.ParseError as e:
                ok = False
                report.append(f"wellformed {n}: PARSE ERROR {e}")

    # every hyperlink r:id in the document must exist in the rels part
    doc = ET.fromstring(z.read("word/document.xml"))
    relsroot = ET.fromstring(z.read("word/_rels/document.xml.rels"))
    declared = {r.get("Id") for r in relsroot}
    used = {h.get(f"{R}id") for h in doc.iter(f"{W}hyperlink")}
    dangling = used - declared
    report.append(f"hyperlinks used={len(used)} declared={len(declared)} "
                  f"dangling={sorted(dangling) if dangling else 'none'}")
    ok &= not dangling

    paras = list(doc.iter(f"{W}p"))
    text = ["".join(t.text or "" for t in p.iter(f"{W}t")) for p in paras]
    report.append(f"paragraphs={len(paras)} nonempty={sum(1 for t in text if t.strip())}")

report.append(f"RESULT: {'VALID' if ok else 'INVALID'}")
report.append("=" * 70)
report.extend(text)
OUT.write_text("\n".join(report), encoding="utf-8")
print("\n".join(report[:len(report) - len(text) - 1]))
