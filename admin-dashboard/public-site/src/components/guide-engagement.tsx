"use client";
import {useEffect} from 'react';
import siteConfig from '@/config/site-config.json';
import {guideVisitKey,returningWithinWindow} from '@/lib/analytics/guide-return';
import {track} from '@/lib/analytics/client';

export function GuideEngagement({contentId}:{contentId:string}) {
 useEffect(()=>{
  if(!siteConfig.analytics.guideMetricsEnabled)return;
  let total=0,previous=performance.now(),activity=performance.now(),started=false,day="";
  const start=()=>{
   if(started||!window.__YOUNEW_ANALYTICS__)return;
   started=true;
   const today=new Date().toISOString().slice(0,10);
   day=today;total=0;
   try { total=Math.min(3600000,Math.max(0,Number(sessionStorage.getItem(`younew.guide-active.${today}.${contentId}.${document.documentElement.lang}`))||0)); } catch {}
   let returning:boolean|undefined;
   try {
    const tabKey='younew.guide-return.'+today;
    const tab= sessionStorage.getItem(tabKey);
    returning=tab===null?returningWithinWindow(localStorage.getItem(guideVisitKey),today):tab==='true';
    sessionStorage.setItem(tabKey,String(returning));
    localStorage.setItem(guideVisitKey,today);
   } catch { returning=undefined; /* Storage failure is N/A, not a new visitor. */ }
   previous=performance.now();activity=previous;
   track({name:'guide_view',contentId,returning});
  };
  const tick=()=>{
   if(started && day!==new Date().toISOString().slice(0,10)){started=false;start();}
   const now=performance.now();
   if(started && window.__YOUNEW_ANALYTICS__ && document.visibilityState==='visible' && now-activity<30000) total=Math.min(3600000,total+Math.min(now-previous,1000));
   previous=now;
  };
  const flush=()=>{tick();if(started&&window.__YOUNEW_ANALYTICS__) {try {sessionStorage.setItem(`younew.guide-active.${day}.${contentId}.${document.documentElement.lang}`,String(total));} catch {} track({name:'guide_active_time',contentId,durationMilliseconds:Math.round(total)});void window.__YOUNEW_ANALYTICS__.flush?.();}};
  const active=()=>{activity=performance.now();};
  const stop=()=>{started=false;total=0;};
  start();window.addEventListener('younew:analytics-ready',start);window.addEventListener('younew:analytics-declined',stop);
  document.addEventListener('visibilitychange',flush);window.addEventListener('pagehide',flush);
  for(const e of ['pointerdown','keydown','scroll'])window.addEventListener(e,active,{passive:true});
  const timer=window.setInterval(tick,1000);const checkpoint=window.setInterval(flush,30000);
  return ()=>{flush();clearInterval(timer);clearInterval(checkpoint);window.removeEventListener('younew:analytics-ready',start);window.removeEventListener('younew:analytics-declined',stop);document.removeEventListener('visibilitychange',flush);window.removeEventListener('pagehide',flush);for(const e of ['pointerdown','keydown','scroll'])window.removeEventListener(e,active);};
 },[contentId]);
 return null;
}
