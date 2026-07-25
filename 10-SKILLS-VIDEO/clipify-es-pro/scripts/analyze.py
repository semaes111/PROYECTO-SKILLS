#!/usr/bin/env python3
import argparse, json, re, sys

def parse(path):
    times, vals, cur = [], [], None
    with open(path, encoding='utf-8', errors='replace') as f:
        for line in f:
            m=re.search(r'pts_time:([0-9.]+)', line)
            if m: cur=float(m.group(1)); continue
            m=re.search(r'lavfi\.signalstats\.YAVG=([0-9.]+)', line)
            if m and cur is not None:
                times.append(cur); vals.append(float(m.group(1))); cur=None
    return times, vals

def main():
    p=argparse.ArgumentParser(); p.add_argument('left'); p.add_argument('right')
    p.add_argument('--min-duration',type=float,default=1.0); p.add_argument('--margin',type=float,default=1.15)
    a=p.parse_args(); tl,vl=parse(a.left); tr,vr=parse(a.right)
    if not vl or not vr: raise SystemExit('ERROR: no se encontraron muestras de movimiento')
    n=min(len(vl),len(vr)); vl,vr,tl=vl[:n],vr[:n],tl[:n]
    def norm(v):
        m=sum(v)/len(v); return [x/m if m else 0 for x in v]
    def smooth(v,w=15):
        return [sum(v[max(0,i-w//2):min(len(v),i+w//2+1)])/len(v[max(0,i-w//2):min(len(v),i+w//2+1)]) for i in range(len(v))]
    l,r=smooth(norm(vl)),smooth(norm(vr)); cur=0 if l[0]>=r[0] else 1; speakers=[]
    for x,y in zip(l,r):
        if cur==0 and y>x*a.margin: cur=1
        elif cur==1 and x>y*a.margin: cur=0
        speakers.append(cur)
    dt=(tl[-1]-tl[0])/(len(tl)-1) if len(tl)>1 and tl[-1]>tl[0] else 1/30
    segs=[]; i=0
    while i<len(speakers):
        j=i
        while j+1<len(speakers) and speakers[j+1]==speakers[i]: j+=1
        segs.append({'start':tl[i], 'end':tl[j]+dt, 'speaker':'left' if speakers[i]==0 else 'right'}); i=j+1
    merged=[]
    for s in segs:
        if merged and s['end']-s['start']<a.min_duration: merged[-1]['end']=s['end']
        elif merged and merged[-1]['speaker']==s['speaker']: merged[-1]['end']=s['end']
        else: merged.append(s)
    print(json.dumps(merged,indent=2,ensure_ascii=False)); print(f'{len(merged)} segmentos',file=sys.stderr)
if __name__=='__main__': main()
