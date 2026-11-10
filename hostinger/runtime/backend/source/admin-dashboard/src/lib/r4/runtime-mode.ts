import 'server-only';
export function productionMode(){
 const mode=process.env.R4_RUNTIME_MODE;
 if(mode&&mode!=='qa'&&mode!=='production')throw new Error('Invalid runtime mode');
 return mode==='production';
}
