'use server';
import {redirect} from 'next/navigation';
import {login,logout,Denied} from '@/lib/r4/security';
export async function signIn(form:FormData){try{await login(form.get('email'),form.get('password'));}catch(e){if(e instanceof Denied)redirect('/login?error='+encodeURIComponent(e.code));throw e;}redirect('/dashboard');}
export async function signOut(){await logout();redirect('/login');}
