"""Keep approved display names across subsequent local animation rebuilds."""
from pathlib import Path
import json,re
ROOT=Path(__file__).resolve().parent
names=json.loads((ROOT/'catalog-names.json').read_text())
def entry(d):
 if d.get('id') in names:
  d['title']=names[d['id']]
  d['tags']=[t for t in d.get('tags',[]) if not re.fullmatch(r'V\d+|方案[一二三四五六七八九十\d]+',t)]
 return d
def title(html,ident):return re.sub(r'<title>.*?</title>','<title>'+names[ident]+'</title>',html,count=1,flags=re.S)
def normalize(text):
 lines=[]
 for line in text.splitlines(keepends=True):
  st=line.strip()
  if st.startswith('animations.push('):
   d=json.loads(st[len('animations.push('):-2])
   if d.get('id') in names:line='      animations.push('+json.dumps(entry(d),ensure_ascii=False)+');\n'
  elif st.startswith('standalonePreviews['):
   m=re.fullmatch(r'standalonePreviews\[("[^"]+")\] = (.*);',st)
   if m and json.loads(m[1]) in names:
    ident=json.loads(m[1]);h=title(json.loads(m[2]),ident)
    line='      standalonePreviews['+m[1]+'] = '+json.dumps(h,ensure_ascii=False).replace('</script','<\\/script')+';\n'
  lines.append(line)
 return ''.join(lines)
def write_changed(path,content):
 if path.read_text()!=content:path.write_text(content)
p=ROOT/'dist/index.html';write_changed(p,normalize(p.read_text()))
for ident in names:
 folder=ROOT/'dist/animations'/ident
 p=folder/'index.html'
 if p.exists():write_changed(p,title(p.read_text(),ident))
 p=folder/'catalog-entry.json'
 if p.exists():write_changed(p,json.dumps(entry(json.loads(p.read_text())),ensure_ascii=False,indent=2)+'\n')
 p=folder/'README.md'
 if p.exists():write_changed(p,re.sub(r'^# [^\n]+','# '+names[ident],p.read_text(),count=1))
# Incremental animation builders match these exact inserted blocks.
for p in (ROOT.parent.parent/'work').glob('*/*insertion.txt'):
 if any('standalonePreviews["'+i+'"]' in p.read_text() for i in names):write_changed(p,normalize(p.read_text()))
