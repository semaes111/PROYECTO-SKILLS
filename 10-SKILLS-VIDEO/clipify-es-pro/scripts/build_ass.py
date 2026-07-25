#!/usr/bin/env python3
import argparse,json

def esc(s): return s.replace('\\','\\\\').replace('{','\\{').replace('}','\\}').replace('\n',' ')
def tm(t):
 h=int(t//3600);m=int(t%3600//60);s=t-h*3600-m*60;return f'{h}:{m:02d}:{s:05.2f}'
p=argparse.ArgumentParser();p.add_argument('json');p.add_argument('out');p.add_argument('--style',default='opus',choices=['opus','karaoke','minimal']);a=p.parse_args()
styles={'opus':('Arial Black',100,3,'&H0000FFFF&',8,3),'karaoke':('Arial Black',110,4,'&H0000FF00&',6,2),'minimal':('Arial',70,6,None,4,1)}
font,size,n,hi,outline,shadow=styles[a.style];data=json.load(open(a.json,encoding='utf-8'));words=[]
for seg in data.get('segments',[]):
 for w in seg.get('words',[]):
  if 'start' in w and 'end' in w and w.get('word','').strip(): words.append({'start':float(w['start']),'end':float(w['end']),'text':esc(w['word'].strip())})
if not words: raise SystemExit('ERROR: JSON sin timestamps de palabras')
head=f'''[Script Info]\nScriptType: v4.00+\nPlayResX: 1080\nPlayResY: 1920\nWrapStyle: 2\nScaledBorderAndShadow: yes\n\n[V4+ Styles]\nFormat: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding\nStyle: Default,{font},{size},&H00FFFFFF,&H000000FF,&H00000000,&H00000000,1,0,0,0,100,100,0,0,1,{outline},{shadow},2,60,60,280,1\n\n[Events]\nFormat: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text\n'''
ev=[]
for k in range(0,len(words),n):
 ch=words[k:k+n]
 for i,w in enumerate(ch):
  end=ch[i+1]['start'] if i+1<len(ch) else ch[-1]['end']; end=max(end,w['start']+.05)
  line=' '.join((f"{{\\c{hi}}}{x['text']}{{\\c&H00FFFFFF&}}" if hi and j==i else x['text']) for j,x in enumerate(ch))
  ev.append(f"Dialogue: 0,{tm(w['start'])},{tm(end)},Default,,0,0,0,,{line}")
open(a.out,'w',encoding='utf-8').write(head+'\n'.join(ev)+'\n')
