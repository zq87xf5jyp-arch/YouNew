import assert from 'node:assert/strict';
import test from 'node:test';
import {readFileSync} from 'node:fs';
import {createRequire} from 'node:module';
const require=createRequire(new URL('../package.json',import.meta.url));
const {transpileModule,ModuleKind,JsxEmit}=require('typescript');
const source=readFileSync(new URL('../src/components/content-media.tsx',import.meta.url),'utf8');
const compiled=transpileModule(source,{compilerOptions:{module:ModuleKind.CommonJS,jsx:JsxEmit.ReactJSX}}).outputText;
const exported: Record<string, import('react').ComponentType<Record<string,unknown>>>={};
const React=require('react'),{renderToStaticMarkup}=require('react-dom/server');
const localRequire=(id:string)=>id==='@/lib/media/image-url'?{responsivePublicImage(){throw new Error('Local image must use actual local variants');}}:id==='@/components/viewport-image'?{ViewportImage:(props:Record<string,unknown>)=>React.createElement('img',props)}:require(id);
new Function('require','exports',compiled)(localRequire,exported);

test('Supernova card, hero and gallery never request an upscaled variant',()=>{
 for(const base of ['/images/place-review','/images/places/missing-photos-20261116'])for(const variant of ['card','hero','gallery']) {
  const html=renderToStaticMarkup(React.createElement(exported.ContentMedia,{asset:{url:`${base}/supernova-1024.webp`,alt:'Temporary balloon arrangement, 2022'},variant}));
  for(const width of [480,800,1024])assert.ok(html.includes(`${base}/supernova-${width}.webp ${width}w`));
  assert.ok(!html.includes('1200.webp'));assert.ok(!html.includes('1920.webp'));
 }
});

test('existing 1200px local place photos retain their original responsive variants',()=>{
 const html=renderToStaticMarkup(React.createElement(exported.ContentMedia,{asset:{url:'/images/places/leiden-stay-parks-20261115/ibis-1200.webp',alt:'Facade'},variant:'hero'}));
 for(const width of [480,800,1200])assert.ok(html.includes(`ibis-${width}.webp ${width}w`));
 assert.ok(!html.includes('1024.webp'));
});
