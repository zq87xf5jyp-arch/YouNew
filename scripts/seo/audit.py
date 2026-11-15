#!/usr/bin/env python3
"""Read-only low-concurrency sitemap/source audit. No credentials or analytics calls."""
import argparse,concurrent.futures,datetime,gzip,hashlib,json,time,urllib.request,urllib.error,urllib.parse,xml.etree.ElementTree as ET
from pathlib import Path
from html.parser import HTMLParser
class Page(HTMLParser):
 def __init__(self):super().__init__();self.canonical=[];self.alternates={};self.robots=[];self.h1=0;self.links=[];self.title='';self.description='';self.in_title=False;self.keywords=False;self.travel=False
 def handle_starttag(self,tag,attrs):
  a=dict(attrs)
  if tag=='h1':self.h1+=1
  if tag=='title':self.in_title=True
  if tag=='a' and a.get('href'):self.links.append(a['href'])
  if tag=='link' and a.get('rel')=='canonical':self.canonical.append(a.get('href'))
  if tag=='link' and a.get('hreflang'):self.alternates[a['hreflang']]=a.get('href')
  if tag=='meta':
   if a.get('name')=='robots':self.robots.append(a.get('content',''))
   if a.get('name')=='description':self.description=a.get('content','')
   if a.get('name')=='keywords':self.keywords=True
   if a.get('name')=='category' and a.get('content')=='travel':self.travel=True
 def handle_endtag(self,tag):
  if tag=='title':self.in_title=False
 def handle_data(self,data):
  if self.in_title:self.title+=data

def fetch(url):
 time.sleep(.12)
 started=time.monotonic()
 try:
  with urllib.request.urlopen(urllib.request.Request(url,headers={'User-Agent':'YouNew-read-only-SEO-audit/1.0','Accept-Encoding':'gzip'}),timeout=25) as r:
   body=r.read(3000000); encoding=r.headers.get('Content-Encoding'); body=gzip.decompress(body) if encoding=='gzip' else body
   text=body.decode('utf-8','replace');p=Page();p.feed(text)
   return dict(url=url,final_url=r.url,status=r.status,seconds=round(time.monotonic()-started,3),sha256=hashlib.sha256(body).hexdigest(),bytes=len(body),canonical=p.canonical,hreflang=p.alternates,h1=p.h1,title=p.title,description=p.description,robots=p.robots,keywords=p.keywords,category_travel=p.travel,links=p.links)
 except urllib.error.HTTPError as e:return dict(url=url,status=e.code,manual_review=e.code in [403,429])
 except Exception as e:return dict(url=url,status=None,error=type(e).__name__)

if __name__=='__main__':
 a=argparse.ArgumentParser();a.add_argument('--output',required=True);a.add_argument('--sources',action='store_true');args=a.parse_args()
 root=Path(__file__).resolve().parents[2]
 if args.sources:urls=[s['url'] for s in json.loads((root/'DataProject/editorial/student-guides-20261111/sources.json').read_text())]
 else:
  body=urllib.request.urlopen('https://younew.nl/sitemap.xml',timeout=30).read();urls=[e.text for e in ET.fromstring(body).iter() if e.tag.endswith('}loc')]
 results=[]
 with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
  for x in pool.map(fetch,urls):results.append(x)
 errors=[x for x in results if x['status']!=200]
 out=dict(checkedAt=datetime.datetime.now(datetime.timezone.utc).isoformat(),scope='official source links' if args.sources else 'all sitemap URLs',count=len(urls),unique=len(set(urls)),errors=errors,results=results)
 Path(args.output).write_text(json.dumps(out,ensure_ascii=False,indent=2)+'\n')
 print(json.dumps(dict(count=len(urls),errors=[{k:v for k,v in x.items() if k in ['url','status','error','manual_review']} for x in errors])))
