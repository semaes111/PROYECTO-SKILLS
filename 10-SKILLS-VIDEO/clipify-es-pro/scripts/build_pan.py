#!/usr/bin/env python3
import json,sys
segs=json.load(open(sys.argv[1],encoding='utf-8'))
if not segs: raise SystemExit('ERROR: lista de segmentos vacía')
lx,rx=int(sys.argv[2]),int(sys.argv[3]); pos=lambda s: lx if s=='left' else rx
expr=str(pos(segs[-1]['speaker']))
for s in reversed(segs[:-1]): expr=f"if(lt(t\\,{float(s['end']):.4f})\\,{pos(s['speaker'])}\\,{expr})"
print(expr)
