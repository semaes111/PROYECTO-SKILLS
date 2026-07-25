#!/usr/bin/env python3
import json,subprocess,sys
cmd=['ffprobe','-v','error','-show_streams','-show_format','-of','json',sys.argv[1]]
try: d=json.loads(subprocess.check_output(cmd,text=True))
except Exception as e: raise SystemExit(f'ERROR ffprobe: {e}')
v=next((s for s in d.get('streams',[]) if s.get('codec_type')=='video'),None)
a=next((s for s in d.get('streams',[]) if s.get('codec_type')=='audio'),None)
if not v: raise SystemExit('ERROR: no hay stream de vídeo')
def fps(x):
 try:
  n,q=x.split('/'); return float(n)/float(q)
 except: return None
print(json.dumps({'width':v.get('width'),'height':v.get('height'),'fps':fps(v.get('avg_frame_rate','0/1')),'rotation':next((int(x.get('rotation',0)) for x in v.get('side_data_list',[]) if 'rotation' in x),0),'duration':float(d.get('format',{}).get('duration') or 0),'has_audio':bool(a)},indent=2))
