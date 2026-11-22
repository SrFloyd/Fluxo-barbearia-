const CACHE='barbosa-caixa-v5';
const APP_SHELL=['./','./index.html','./manifest.webmanifest'];
self.addEventListener('install',event=>{
 event.waitUntil(caches.open(CACHE).then(cache=>cache.addAll(APP_SHELL)));
 self.skipWaiting();
});
self.addEventListener('activate',event=>{
 event.waitUntil((async()=>{
  const keys=await caches.keys();
  await Promise.all(keys.filter(key=>key!==CACHE).map(key=>caches.delete(key)));
  await self.clients.claim();
 })());
});
self.addEventListener('fetch',event=>{
 const request=event.request;
 if(request.method!=='GET')return;
 const url=new URL(request.url);
 const shell=request.mode==='navigate'||url.pathname.endsWith('/index.html')||url.pathname.endsWith('/manifest.webmanifest');
 if(shell){
  event.respondWith((async()=>{
   try{
    const response=await fetch(request);
    if(response&&response.ok){const cache=await caches.open(CACHE);cache.put(request,response.clone());}
    return response;
   }catch(error){
    const cached=await caches.match(request)||await caches.match('./index.html');
    if(cached)return cached;
    throw error;
   }
  })());
  return;
 }
 event.respondWith((async()=>{
  const cached=await caches.match(request);
  if(cached)return cached;
  const response=await fetch(request);
  if(response&&response.ok&&url.origin===self.location.origin){
   const cache=await caches.open(CACHE);cache.put(request,response.clone());
  }
  return response;
 })());
});
