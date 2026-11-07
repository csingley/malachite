"""Reads the evaluation report and scans the sources. See default.nix.

Usage: check.py REPORT.json SOURCE_DIR
Exit status 1 if a FAIL was printed. WARN lines are informational.
"""
import json
import os
import re
import sys

report = json.load(open(sys.argv[1]))
src = sys.argv[2]
roles = set(report["canonicalRoles"])
fails = []
warns = []


def fail(msg):
    fails.append(msg)


def check_colors(kind, name, p, with_slots):
    if set(p["roles"]) != roles:
        fail(f"{kind} {name}: roles differ from the contract: {sorted(set(p['roles']) ^ roles)}")
    if not p["allHex"]:
        fail(f"{kind} {name}: a role, slot or ANSI color is not #rrggbb")
    if p["ansiLength"] != 16:
        fail(f"{kind} {name}: ANSI length {p['ansiLength']}, expected 16")
    if not p["json"]:
        fail(f"{kind} {name}: the colorscheme does not serialize to JSON")


# --- every scheme in nixpkgs' base16-schemes -------------------------------------------------
schemes = report["schemes"]
for name, s in sorted(schemes.items()):
    if s["nslots"] != 16:
        fail(f"scheme {name}: {s['nslots']} slots parsed, expected 16")
    check_colors("scheme", name, s, False)
    if not s["roundTrip"]:
        fail(f"scheme {name}: the slots in use do not survive scheme -> roles -> slots")

# --- the flavors and the fixture -----------------------------------------------------------------
for group in ("flavors", "fixtures"):
    for name, p in sorted(report[group].items()):
        check_colors(group[:-1], name, p, True)
        if p["format"] != 1:
            fail(f"{group[:-1]} {name}: format is {p['format']}, expected 1")
        for role, bar in (("fg", 4.5), ("fg_muted", 4.5), ("fg_subtle", 4.5), ("error", 3.0), ("keyword", 3.0)):
            if p["contrast"][role] < bar:
                warns.append(f"{group[:-1]} {name}: {role} is {p['contrast'][role]:.1f}:1 on bg (bar {bar})")

# --- legibility over the schemes (warnings only) ------------------------------------------
N = len(schemes)


def below(role, bar):
    return sorted(n for n, s in schemes.items() if s["contrast"][role] < bar)


legib = [
    ("fg", 4.5),
    ("fg_muted", 4.5),
    ("fg_subtle", 4.5),
    ("error", 3.0),
    ("warning", 3.0),
    ("success", 3.0),
    ("accent", 3.0),
    ("keyword", 3.0),
]
summary = []
for role, bar in legib:
    b = below(role, bar)
    summary.append(f"  {role:10} below {bar}:1 on bg in {len(b):3d} of {N} schemes")
raw_muted = sum(1 for s in schemes.values() if s["contrast"]["fg_muted_unadjusted"] < 4.5)
raw_subtle = sum(1 for s in schemes.values() if s["contrast"]["fg_subtle_unadjusted"] < 4.5)
adj_muted = len(below("fg_muted", 4.5))
adj_subtle = len(below("fg_subtle", 4.5))
summary.append(
    f"  the legibility adjustment lowers fg_muted below 4.5:1 from {raw_muted} to {adj_muted} schemes, "
    f"fg_subtle from {raw_subtle} to {adj_subtle}"
)
summary.append(f"  (the rest have an fg that is itself under 4.5:1: {len(below('fg', 4.5))} schemes)")

# --- role names used in the sources must exist -----------------------------------------------
# `c.` in colorschemes, `r.` and `roles.` in the library, `self.` in mkColorscheme.nix,
# `colorscheme.roles.` in ports.
NIX = re.compile(r"\b(?:c|r|roles|colorscheme\.roles|first\.roles)\.([a-z][a-z0-9_]*)\b")
NIX_SELF = re.compile(r"\bself\.([a-z][a-z0-9_]*)\b")
CSS = re.compile(r"@([a-z][a-z0-9_]*)\b")
LUA = re.compile(r"\b(?:P|pal\.P|data)\.([a-z][a-z0-9_]*)\b")
css_at_rules = {"keyframes", "define", "import", "media", "font", "charset", "supports"}
extras = {"nix": set(), "css": set(), "lua": {"ansi", "panel", "panel_subtle"}}


def strip_comments(text, kind):
    """Remove comments, keeping line numbers (a comment may mention old names)."""
    if kind == "css":
        return re.sub(r"/\*.*?\*/", lambda m: "\n" * m.group(0).count("\n"), text, flags=re.S)
    if kind == "lua":
        return re.sub(r"--.*$", "", text, flags=re.M)
    # nix: a comment is a # followed by a space (a hex color is "#rrggbb")
    return re.sub(r"(^|\s)#(\s.*)?$", "", text, flags=re.M)


used = {}
for root, dirs, files in os.walk(src):
    dirs[:] = [d for d in dirs if d not in (".git", "samples", "docs", "result")]
    for f in files:
        path = os.path.join(root, f)
        rel = os.path.relpath(path, src)
        if f.endswith(".nix") and rel not in ("checks/default.nix",):
            rx, kind = (NIX_SELF if rel == "lib/mkColorscheme.nix" else NIX), "nix"
        elif f.endswith(".css"):
            rx, kind = CSS, "css"
        elif f.endswith(".lua"):
            rx, kind = LUA, "lua"
        else:
            continue
        text = strip_comments(open(path, errors="ignore").read(), kind)
        scanners = [(rx, kind)]
        if rel == "lib/mkColorscheme.nix":
            scanners.append((NIX, kind))
        for rx2, kind2 in scanners:
            for lineno, line in enumerate(text.split("\n"), 1):
                for m in rx2.finditer(line):
                    name = m.group(1)
                    if kind2 == "css" and (name in css_at_rules or line.lstrip().startswith("@define-color")):
                        continue
                    if name in roles or name in extras.get(kind2, set()):
                        used[name] = used.get(name, 0) + 1
                        continue
                    fail(f"{rel}:{lineno}: `{m.group(0)}` is not a role in the contract")

# --- report ------------------------------------------------------------------------------------
print(
    f"malachite check: {N} Base16 schemes, {len(report['flavors'])} flavors, "
    f"{len(report['fixtures'])} fixture, {len(roles)} roles"
)
print("legibility over the schemes (warnings only):")
print("\n".join(summary))
if warns:
    print("flavor warnings:")
    print("\n".join("  " + w for w in warns))
if fails:
    print(f"\n{len(fails)} FAILED:")
    print("\n".join("  FAIL " + f for f in fails[:40]))
    sys.exit(1)
print("all checks passed")
