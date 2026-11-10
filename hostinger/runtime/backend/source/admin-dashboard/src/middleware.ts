import {NextResponse,type NextRequest} from 'next/server';
export function middleware(req:NextRequest){const p=req.nextUrl.pathname;
 if(/^\/(rest|storage|auth|functions)\//.test(p))return NextResponse.json({error:'not_found'},{status:404});
 if(req.method!=='GET'&&req.method!=='HEAD'&&!p.startsWith('/api/r4/')&&!['/login','/dashboard','/business-inquiries','/content'].includes(p)&&!/^\/business-inquiries\/[0-9a-f-]{36}$/.test(p))return NextResponse.json({error:'method_not_allowed'},{status:405});
 if(p.startsWith('/api/')&&!p.startsWith('/api/r4/'))return NextResponse.json({error:'not_migrated'},{status:404,headers:{'Cache-Control':'no-store'}});
 const r=NextResponse.next();r.headers.set('Cache-Control','private, no-store');return r;
}
export const config={matcher:['/((?!_next/static|_next/image|favicon.ico).*)']};
