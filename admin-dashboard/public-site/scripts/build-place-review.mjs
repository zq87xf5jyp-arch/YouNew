import {spawnSync} from 'node:child_process';
import {readdir,readFile,writeFile,rm} from 'node:fs/promises';
import {fileURLToPath} from 'node:url';
import {placeReviewBatch} from './place-review.mjs';
const site=fileURLToPath(new URL('../',import.meta.url));
const env={...process.env,YOUNEW_PLACE_REVIEW:placeReviewBatch,YOUNEW_PRIVATE_REVIEW_BUILD:'1',YOUNEW_ATOMIC_BUILD:'1'};
try {
  const build=spawnSync('bash',['scripts/build.sh'],{cwd:site,env,stdio:'inherit'});
  if(build.status!==0)throw Error(`Review build failed (${build.status})`);
  const walk=async p=>{for(const e of await readdir(p,{withFileTypes:true})){const f=`${p}/${e.name}`;if(e.isDirectory())await walk(f);else if(e.name.endsWith('.html')){let html=await readFile(f,'utf8');html=html.replace(/<meta\b[^>]*name="(?:robots|googlebot)"[^>]*>/gi,'').replace('</head>','<meta name="robots" content="noindex,nofollow,noarchive"/></head>');await writeFile(f,html);}}};
  await walk(`${site}/out`);
  await writeFile(`${site}/out/robots.txt`,'User-agent: *\nDisallow: /\n');
  await writeFile(`${site}/out/sitemap.xml`,'<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"/>');
  await writeFile(`${site}/out/PRIVATE-REVIEW.json`,JSON.stringify({batchId:placeReviewBatch,publicationAuthorized:false,requiresAccessControl:true})+'\n');
  console.log('PRIVATE REVIEW ONLY. Serve on loopback or behind access control; never deploy to production.');
} finally {await rm(`${site}/public/images/place-review`,{recursive:true,force:true});}
