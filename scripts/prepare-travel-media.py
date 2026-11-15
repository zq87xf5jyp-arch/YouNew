#!/usr/bin/env python3
"""Prepare licensed Commons candidates, never activate them in runtime.
Uses allowed public file-description pages, not robots-disallowed API/search endpoints.
"""
import csv,html,importlib.util,json,re,shutil,subprocess,tempfile,urllib.parse
from pathlib import Path
spec=importlib.util.spec_from_file_location('prep',Path(__file__).with_name('prepare-travel-expansion.py'));p=importlib.util.module_from_spec(spec);spec.loader.exec_module(p)
DIR=p.DIR;ROOT=p.ROOT

def plain(s):
 parser=p.Text();parser.feed(s);return ' '.join(parser.parts)
def main():
 rows=list(csv.DictReader((DIR/'curated.tsv').open(),delimiter='\t'));ids={r['id'] for r in rows};candidates=[]
 old=ROOT/'DataProject/batches/WP-06/M2-amsterdam-001.json'
 for r in json.loads(old.read_text())['records']:
  if r['id'] not in ids:continue
  images=[i for i in r['images'] if 'commons.wikimedia.org' in i['source_page_url']]
  if images:
   image=images[0];name=urllib.parse.unquote(urllib.parse.urlsplit(image['asset_url']).path.split('/')[-1]);candidates.append({'id':r['id'],'url':'https://commons.wikimedia.org/wiki/File:'+urllib.parse.quote(name),'origin':str(old.relative_to(ROOT))})
 for eid,name in [('museum.leiden-de-valk','MolenDeValkLeiden.jpg'),('place.rotterdam-euromast','Euromast @ Rotterdam (29972520534).jpg'),('museum.den-haag-mauritshuis','Mauritshuis Den Haag.jpg'),('place.utrecht-domtoren','Utrecht Dom Tower by Night.jpg')]:candidates.append({'id':eid,'url':'https://commons.wikimedia.org/wiki/File:'+urllib.parse.quote(name),'origin':'Commons file search'})
 discovery=DIR/'media-discovery.json'
 if discovery.exists():
  excluded={'museum.den-haag-fotomuseum','nature.leiden-rembrandtpark','museum.rotterdam-foto','place.rotterdam-blijdorp','museum.eindhoven-van-abbe','place.eindhoven-muziekgebouw','place.eindhoven-piet-hein-eek'}
  candidates.extend(c for c in json.loads(discovery.read_text())['candidates'] if c['id'] not in excluded)
 # Existing research already selected these exact files; retain its provenance.
 nature=ROOT/'DataProject/editorial/leiden-nature-culture-20261115/media-evidence.json'
 candidates.extend({'id':c['entityID'],'url':c['sourcePageURL'],'origin':str(nature.relative_to(ROOT))} for c in json.loads(nature.read_text())['candidates'] if c['entityID'] in {'nature.leiden-plantsoen','nature.leiden-cronesteyn'})
 for c in candidates:
  out=DIR/'media-evidence'/f'{c["id"]}.json'
  previous=json.loads(out.read_text()) if out.exists() else None
  if previous:continue  # Cached failures require an explicit reviewed retry, never a retry loop.
  e={**c,'status':'needs_review','publicationAuthorized':False,'checkedAt':p.TODAY,'visualIdentityChecked':False,'files':[]}
  if previous:e['previousAttempts']=[{'checkedAt':previous['checkedAt'],'limitation':previous['limitation']}]
  try:
   if shutil.disk_usage(DIR).free<200*1024*1024:raise ValueError('Free space below 200 MiB reserve; no further image download')
   allowed,rhash,rstate=p.permission(c['url']);e['robotsSHA256']=rhash
   if not allowed:raise ValueError('robots disallowed or unavailable')
   b,status,final,ct=p.request(c['url']);s=html.unescape(b.decode('utf8'));e['sourcePageSHA256']=p.sha(b)
   author=re.search(r'id="fileinfotpl_aut"[^>]*>.*?</td>\s*<td[^>]*>(.*?)</td>',s,re.S)
   assert author,'No explicit author field';e['author']=plain(author[1])
   license_links=re.findall(r'<span class="licensetpl_link"[^>]*>(.*?)</span>',s,re.S)
   licenses=re.findall(r'https?://creativecommons.org/licenses/(by(?:-sa)?)/(\d\.\d)', ' '.join(license_links))
   assert licenses,'No supported commercial CC license in Licensing section';kind,version=licenses[0]
   e['license']='CC '+kind.upper()+' '+version;e['licenseURL']=f'https://creativecommons.org/licenses/{kind}/{version}/';e['shareAlike']=kind=='by-sa';e['changes']='Resized and re-encoded as WebP; no crop or generated content.'
   e['attribution']=f'{urllib.parse.unquote(c["url"].split("File:")[-1])} — {e["author"]} — {e["license"]}'
   image=re.search(r'class="fullImageLink".*?<a href="([^"]+)".*?<img[^>]* src="([^"]+)"',s,re.S);assert image,'No original image'
   e['originalURL']=image[1].split('?')[0];download=re.sub(r'/\d+px-', '/1280px-',image[2].split('?')[0]);e['downloadURL']=download
   allowed,_,_=p.permission(download)
   assert allowed,'Image host robots unavailable or disallowed'
   data,_,finalURL,ct=p.request(download);e['downloadSHA256']=p.sha(data)
   with tempfile.TemporaryDirectory(prefix='younew-media-') as temp:
    original=Path(temp)/'source';original.write_bytes(data)
    for width in [480,800,1200]:
     file=DIR/'media'/f'{c["id"]}-{width}.webp';file.parent.mkdir(exist_ok=True)
     subprocess.run(['/opt/homebrew/bin/cwebp','-quiet','-q','80','-resize',str(width),'0',str(original),'-o',str(file)],check=True,capture_output=True)
     e['files'].append({'path':str(file.relative_to(ROOT)),'width':width,'sha256':p.sha(file.read_bytes()),'bytes':file.stat().st_size})
   e['licenseMetadataExtracted']=True
   e['rightsEvidenceChecked']=False
   e['reviewNote']='License template extracted; human licensing and attribution review required before activation.'
  except Exception as ex:e['limitation']=str(ex)[:200]
  p.write(out,e);print(c['id'],len(e['files']),e.get('limitation','prepared; visual identity pending'),flush=True)
if __name__=='__main__':main()
