#!/usr/bin/env python3
"""Bounded review derivatives; keep a 200 MiB reserve and never touch runtime."""
import html, importlib.util, json, re, shutil, subprocess, tempfile
from pathlib import Path
spec=importlib.util.spec_from_file_location('prep',Path(__file__).with_name('prepare-travel-expansion.py'))
p=importlib.util.module_from_spec(spec);spec.loader.exec_module(p)
out=p.ROOT/'DataProject/research/travel-gap-review-20261115'
previous=p.ROOT/'DataProject/research/travel-media-followup-20261115'
for path in sorted(previous.glob('*.json')):
    old=json.loads(path.read_text());eid=old['id'];dest=out/'media-evidence'/(eid+'.json')
    if dest.exists():print(eid,'cached');continue
    e={**old,'previousEvidence':{'path':str(path.relative_to(p.ROOT)),'sha256':p.sha(path.read_bytes())},'files':[]}
    if eid=='museum.eindhoven-prehistorisch-dorp':
        e['limitation']='Conflicting photographer/EXIF identity unresolved; no download or approval proposal.'
        p.write(dest,e);continue
    try:
        assert shutil.disk_usage(out).free>200*1024*1024,'Below 200 MiB reserve; no image download'
        allowed,_,_=p.permission(old['sourceURL']);assert allowed,'robots unavailable or disallowed'
        b,_,_,_=p.request(old['sourceURL']);e['currentSourcePageSHA256']=p.sha(b);page=html.unescape(b.decode())
        assert old['licenseURL'].rstrip('/') in page,'License metadata changed; stop'
        image=re.search(r'class="fullImageLink".*?<a href="([^"]+)".*?<img[^>]* src="([^"]+)"',page,re.S);assert image
        url=image[2].split('?')[0];e['downloadURL']=url;e['originalURL']=image[1].split('?')[0]
        allowed,_,_=p.permission(url);assert allowed,'image robots unavailable or disallowed'
        data,_,_,_=p.request(url);e['downloadSHA256']=p.sha(data)
        assert shutil.disk_usage(out).free>200*1024*1024,'Below reserve after request; no derivative write'
        with tempfile.TemporaryDirectory(prefix='younew-gap-image-') as tmp:
            src=Path(tmp)/'source';src.write_bytes(data)
            target=out/'media'/(eid+'.webp');target.parent.mkdir(parents=True,exist_ok=True)
            subprocess.run(['/opt/homebrew/bin/cwebp','-quiet','-q','82',str(src),'-o',str(target)],check=True,capture_output=True)
            e['files']=[{'path':str(target.relative_to(p.ROOT)),'sha256':p.sha(target.read_bytes()),'bytes':target.stat().st_size}]
        e['changes']='Commons display-size derivative re-encoded as WebP; no crop, upscale or generated content.'
        e['visualIdentityChecked']=False;e['rightsEvidenceChecked']=False
    except Exception as error:e['limitation']=str(error)[:240]
    p.write(dest,e);print(eid,len(e['files']),e.get('limitation','visual review pending'),flush=True)
