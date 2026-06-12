#!/usr/bin/env python3
"""Regenera INDICE-MAESTRO-SKILLS.md detectando formato flat (*-SKILL.md) y folder (dir/SKILL.md),
más categorías especiales 20 (agentes) y 21 (hooks)."""
import re
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent

def fm(file_path):
    try:
        c = file_path.read_text(encoding='utf-8', errors='replace')
        if not c.startswith('---'): return {}
        body = c.split('---', 2)
        if len(body) < 3: return {}
        d = {}
        for line in body[1].strip().split('\n'):
            if ':' in line and not line.startswith(' '):
                k, v = line.split(':', 1)
                d[k.strip()] = v.strip().strip('"\'')
        return d
    except Exception:
        return {}

def skills_in(cat):
    out = []
    for item in sorted(cat.iterdir()):
        if item.is_file() and item.name.endswith('-SKILL.md'):
            f = fm(item)
            out.append((f.get('name', item.stem[:-6]), 'flat', f.get('origin',''),
                        sum(1 for _ in item.open(errors='replace')), str(item.relative_to(REPO)),
                        f.get('description','')[:80].replace('|','/')))
        elif item.is_dir() and (item/'SKILL.md').exists():
            sf = item/'SKILL.md'; f = fm(sf)
            out.append((f.get('name', item.name), 'folder', f.get('origin',''),
                        sum(1 for _ in sf.open(errors='replace')), str(sf.relative_to(REPO)),
                        f.get('description','')[:80].replace('|','/')))
    return out

cats = sorted(d for d in REPO.iterdir() if d.is_dir() and re.match(r'^\d{2}-SKILLS-', d.name))
agents_dir = REPO/'20-AGENTES-SUBAGENTS'
hooks_dir = REPO/'21-HOOKS-RUNTIME'

lines = ['# ÍNDICE MAESTRO DE SKILLS', '',
         '> Generado por scripts/regenerate-index.py — no editar a mano.', '']
total = 0
toc, sections = [], []
for cat in cats:
    sk = skills_in(cat)
    total += len(sk)
    toc.append(f'- [{cat.name}](#{cat.name.lower()}) ({len(sk)} skills)')
    sec = [f'\n## {cat.name}\n', f'**{len(sk)} skills**\n',
           '| Skill | Formato | Origen | Líneas | Descripción |',
           '|-------|---------|--------|--------|-------------|']
    for name, fmt, origin, nl, path, desc in sk:
        badge = 'ECC' if origin == 'ECC' else 'propia'
        sec.append(f'| [{name}]({path}) | {fmt} | {badge} | {nl} | {desc} |')
    sections.append('\n'.join(sec))

agents = sorted(agents_dir.glob('*.md')) if agents_dir.exists() else []
agents = [a for a in agents if a.name != 'README.md']
hooks = sorted((hooks_dir/'scripts').glob('*.js')) if (hooks_dir/'scripts').exists() else []

lines.append(f'**Total: {total} skills** + {len(agents)} agentes (cat. 20) + {len(hooks)} hooks (cat. 21)\n')
lines.append('## Tabla de Contenidos\n')
lines += toc
if agents: lines.append(f'- [20-AGENTES-SUBAGENTS](#20-agentes-subagents) ({len(agents)} agentes)')
if hooks: lines.append(f'- [21-HOOKS-RUNTIME](#21-hooks-runtime) ({len(hooks)} hooks)')
lines.append('\n---')
lines += sections

if agents:
    lines.append('\n## 20-AGENTES-SUBAGENTS\n')
    lines.append('| Agente | Origen | Modelo |')
    lines.append('|--------|--------|--------|')
    for a in agents:
        f = fm(a)
        lines.append(f"| [{a.stem}](20-AGENTES-SUBAGENTS/{a.name}) | {f.get('origin','propia')} | {f.get('model','-')} |")
if hooks:
    lines.append('\n## 21-HOOKS-RUNTIME\n')
    lines.append('Ver [README](21-HOOKS-RUNTIME/README.md) e [INSTALACION](21-HOOKS-RUNTIME/INSTALACION.md).\n')
    for h in hooks:
        lines.append(f'- `{h.name}`')

(REPO/'INDICE-MAESTRO-SKILLS.md').write_text('\n'.join(lines) + '\n', encoding='utf-8')
print(f'✅ Índice: {total} skills, {len(agents)} agentes, {len(hooks)} hooks en {len(cats)} categorías')
