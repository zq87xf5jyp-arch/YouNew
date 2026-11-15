import {readFile, writeFile, mkdir} from 'node:fs/promises';
import {createHash} from 'node:crypto';
import {fileURLToPath} from 'node:url';
import {projectPracticalGuideDraft} from './practical-guide.mjs';
const root=fileURLToPath(new URL('../../../',import.meta.url));
const directory=`${root}DataProject/editorial/student-guides-20261111/`;
const target=new URL('../src/generated/guide-review.json',import.meta.url);
const manifest=JSON.parse(await readFile(`${directory}manifest.json`,'utf8'));
const guides=[];
for(const item of manifest.guides) for(const file of item.files) {
  const raw=JSON.parse(await readFile(`${directory}${file}`,'utf8'));
  guides.push({code:item.code,blockers:item.blockers,guide:projectPracticalGuideDraft(raw,{id:item.id,language:raw.locale,route:raw.seo.canonicalPath})});
}
const digest=createHash('sha256').update(JSON.stringify(guides)).digest('hex');
await mkdir(new URL('../src/generated/',import.meta.url),{recursive:true});
await writeFile(target,JSON.stringify({schemaVersion:1,enabled:process.env.YOUNEW_GUIDE_REVIEW==='1',digest,guides:process.env.YOUNEW_GUIDE_REVIEW==='1'?guides:[]},null,2)+'\n');
console.log(`Guide drafts: ${guides.length} validated; preview ${process.env.YOUNEW_GUIDE_REVIEW==='1'?'enabled (private only)':'excluded'}; SHA256 ${digest}`);
