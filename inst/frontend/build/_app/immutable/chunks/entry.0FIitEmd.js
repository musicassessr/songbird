import{D as nt}from"./scheduler.Ry1FEY9V.js";import{w as _e}from"./index.brOo8pp7.js";new URL("sveltekit-internal://");function at(e,t){return e==="/"||t==="ignore"?e:t==="never"?e.endsWith("/")?e.slice(0,-1):e:t==="always"&&!e.endsWith("/")?e+"/":e}function rt(e){return e.split("%25").map(decodeURI).join("%25")}function ot(e){for(const t in e)e[t]=decodeURIComponent(e[t]);return e}function le({href:e}){return e.split("#")[0]}const st=["href","pathname","search","toString","toJSON"];function it(e,t,n){const a=new URL(e);Object.defineProperty(a,"searchParams",{value:new Proxy(a.searchParams,{get(r,o){if(o==="get"||o==="getAll"||o==="has")return s=>(n(s),r[o](s));t();const i=Reflect.get(r,o);return typeof i=="function"?i.bind(r):i}}),enumerable:!0,configurable:!0});for(const r of st)Object.defineProperty(a,r,{get(){return t(),e[r]},enumerable:!0,configurable:!0});return a}const ct="/__data.json",lt=".html__data.json";function ft(e){return e.endsWith(".html")?e.replace(/\.html$/,lt):e.replace(/\/$/,"")+ct}function ut(...e){let t=5381;for(const n of e)if(typeof n=="string"){let a=n.length;for(;a;)t=t*33^n.charCodeAt(--a)}else if(ArrayBuffer.isView(n)){const a=new Uint8Array(n.buffer,n.byteOffset,n.byteLength);let r=a.length;for(;r;)t=t*33^a[--r]}else throw new TypeError("value must be a string or TypedArray");return(t>>>0).toString(36)}const je=window.fetch;window.fetch=(e,t)=>((e instanceof Request?e.method:t?.method||"GET")!=="GET"&&C.delete(me(e)),je(e,t));const C=new Map;function dt(e){const t=atob(e),n=new Uint8Array(t.length);for(let a=0;a<t.length;a++)n[a]=t.charCodeAt(a);return n.buffer}function pt(e,t){const n=me(e,t),a=document.querySelector(n);if(a?.textContent){let{body:r,...o}=JSON.parse(a.textContent);const i=a.getAttribute("data-ttl");return i&&C.set(n,{body:r,init:o,ttl:1e3*Number(i)}),a.getAttribute("data-b64")!==null&&(r=dt(r)),Promise.resolve(new Response(r,o))}return window.fetch(e,t)}function ht(e,t,n){if(C.size>0){const a=me(e,n),r=C.get(a);if(r){if(performance.now()<r.ttl&&["default","force-cache","only-if-cached",void 0].includes(n?.cache))return new Response(r.body,r.init);C.delete(a)}}return window.fetch(t,n)}function me(e,t){let a=`script[data-sveltekit-fetched][data-url=${JSON.stringify(e instanceof Request?e.url:e)}]`;if(t?.headers||t?.body){const r=[];t.headers&&r.push([...new Headers(t.headers)].join(",")),t.body&&(typeof t.body=="string"||ArrayBuffer.isView(t.body))&&r.push(t.body),a+=`[data-hash="${ut(...r)}"]`}return a}const gt=/^(\[)?(\.\.\.)?(\w+)(?:=(\w+))?(\])?$/;function _t(e){const t=[];return{pattern:e==="/"?/^\/$/:new RegExp(`^${yt(e).map(a=>{const r=/^\[\.\.\.(\w+)(?:=(\w+))?\]$/.exec(a);if(r)return t.push({name:r[1],matcher:r[2],optional:!1,rest:!0,chained:!0}),"(?:/(.*))?";const o=/^\[\[(\w+)(?:=(\w+))?\]\]$/.exec(a);if(o)return t.push({name:o[1],matcher:o[2],optional:!0,rest:!1,chained:!0}),"(?:/([^/]+))?";if(!a)return;const i=a.split(/\[(.+?)\](?!\])/);return"/"+i.map((c,l)=>{if(l%2){if(c.startsWith("x+"))return fe(String.fromCharCode(parseInt(c.slice(2),16)));if(c.startsWith("u+"))return fe(String.fromCharCode(...c.slice(2).split("-").map(h=>parseInt(h,16))));const d=gt.exec(c),[,g,u,f,p]=d;return t.push({name:f,matcher:p,optional:!!g,rest:!!u,chained:u?l===1&&i[0]==="":!1}),u?"(.*?)":g?"([^/]*)?":"([^/]+?)"}return fe(c)}).join("")}).join("")}/?$`),params:t}}function mt(e){return!/^\([^)]+\)$/.test(e)}function yt(e){return e.slice(1).split("/").filter(mt)}function vt(e,t,n){const a={},r=e.slice(1),o=r.filter(s=>s!==void 0);let i=0;for(let s=0;s<t.length;s+=1){const c=t[s];let l=r[s-i];if(c.chained&&c.rest&&i&&(l=r.slice(s-i,s+1).filter(d=>d).join("/"),i=0),l===void 0){c.rest&&(a[c.name]="");continue}if(!c.matcher||n[c.matcher](l)){a[c.name]=l;const d=t[s+1],g=r[s+1];d&&!d.rest&&d.optional&&g&&c.chained&&(i=0),!d&&!g&&Object.keys(a).length===o.length&&(i=0);continue}if(c.optional&&c.chained){i++;continue}return}if(!i)return a}function fe(e){return e.normalize().replace(/[[\]]/g,"\\$&").replace(/%/g,"%25").replace(/\//g,"%2[Ff]").replace(/\?/g,"%3[Ff]").replace(/#/g,"%23").replace(/[.*+?^${}()|\\]/g,"\\$&")}function wt({nodes:e,server_loads:t,dictionary:n,matchers:a}){const r=new Set(t);return Object.entries(n).map(([s,[c,l,d]])=>{const{pattern:g,params:u}=_t(s),f={id:s,exec:p=>{const h=g.exec(p);if(h)return vt(h,u,a)},errors:[1,...d||[]].map(p=>e[p]),layouts:[0,...l||[]].map(i),leaf:o(c)};return f.errors.length=f.layouts.length=Math.max(f.errors.length,f.layouts.length),f});function o(s){const c=s<0;return c&&(s=~s),[c,e[s]]}function i(s){return s===void 0?s:[r.has(s),e[s]]}}function De(e,t=JSON.parse){try{return t(sessionStorage[e])}catch{}}function Le(e,t,n=JSON.stringify){const a=n(t);try{sessionStorage[e]=a}catch{}}const S=globalThis.__sveltekit_car9x6?.base??"",bt=globalThis.__sveltekit_car9x6?.assets??S,Et="1720054926689",$e="sveltekit:snapshot",Ce="sveltekit:scroll",Ve="sveltekit:states",kt="sveltekit:pageurl",N="sveltekit:history",F="sveltekit:navigation",Y={tap:1,hover:2,viewport:3,eager:4,off:-1,false:-1},H=location.origin;function Fe(e){if(e instanceof URL)return e;let t=document.baseURI;if(!t){const n=document.getElementsByTagName("base");t=n.length?n[0].href:document.URL}return new URL(e,t)}function ye(){return{x:pageXOffset,y:pageYOffset}}function T(e,t){return e.getAttribute(`data-sveltekit-${t}`)}const Pe={...Y,"":Y.hover};function Ge(e){let t=e.assignedSlot??e.parentNode;return t?.nodeType===11&&(t=t.host),t}function Me(e,t){for(;e&&e!==t;){if(e.nodeName.toUpperCase()==="A"&&e.hasAttribute("href"))return e;e=Ge(e)}}function pe(e,t){let n;try{n=new URL(e instanceof SVGAElement?e.href.baseVal:e.href,document.baseURI)}catch{}const a=e instanceof SVGAElement?e.target.baseVal:e.target,r=!n||!!a||ee(n,t)||(e.getAttribute("rel")||"").split(/\s+/).includes("external"),o=n?.origin===H&&e.hasAttribute("download");return{url:n,external:r,target:a,download:o}}function J(e){let t=null,n=null,a=null,r=null,o=null,i=null,s=e;for(;s&&s!==document.documentElement;)a===null&&(a=T(s,"preload-code")),r===null&&(r=T(s,"preload-data")),t===null&&(t=T(s,"keepfocus")),n===null&&(n=T(s,"noscroll")),o===null&&(o=T(s,"reload")),i===null&&(i=T(s,"replacestate")),s=Ge(s);function c(l){switch(l){case"":case"true":return!0;case"off":case"false":return!1;default:return}}return{preload_code:Pe[a??"off"],preload_data:Pe[r??"off"],keepfocus:c(t),noscroll:c(n),reload:c(o),replace_state:c(i)}}function xe(e){const t=_e(e);let n=!0;function a(){n=!0,t.update(i=>i)}function r(i){n=!1,t.set(i)}function o(i){let s;return t.subscribe(c=>{(s===void 0||n&&c!==s)&&i(s=c)})}return{notify:a,set:r,subscribe:o}}function At(){const{set:e,subscribe:t}=_e(!1);let n;async function a(){clearTimeout(n);try{const r=await fetch(`${bt}/_app/version.json`,{headers:{pragma:"no-cache","cache-control":"no-cache"}});if(!r.ok)return!1;const i=(await r.json()).version!==Et;return i&&(e(!0),clearTimeout(n)),i}catch{return!1}}return{subscribe:t,check:a}}function ee(e,t){return e.origin!==H||!e.pathname.startsWith(t)}const St=-1,Rt=-2,It=-3,Lt=-4,Pt=-5,xt=-6;function Ut(e,t){if(typeof e=="number")return r(e,!0);if(!Array.isArray(e)||e.length===0)throw new Error("Invalid input");const n=e,a=Array(n.length);function r(o,i=!1){if(o===St)return;if(o===It)return NaN;if(o===Lt)return 1/0;if(o===Pt)return-1/0;if(o===xt)return-0;if(i)throw new Error("Invalid input");if(o in a)return a[o];const s=n[o];if(!s||typeof s!="object")a[o]=s;else if(Array.isArray(s))if(typeof s[0]=="string"){const c=s[0],l=t?.[c];if(l)return a[o]=l(r(s[1]));switch(c){case"Date":a[o]=new Date(s[1]);break;case"Set":const d=new Set;a[o]=d;for(let f=1;f<s.length;f+=1)d.add(r(s[f]));break;case"Map":const g=new Map;a[o]=g;for(let f=1;f<s.length;f+=2)g.set(r(s[f]),r(s[f+1]));break;case"RegExp":a[o]=new RegExp(s[1],s[2]);break;case"Object":a[o]=Object(s[1]);break;case"BigInt":a[o]=BigInt(s[1]);break;case"null":const u=Object.create(null);a[o]=u;for(let f=1;f<s.length;f+=2)u[s[f]]=r(s[f+1]);break;default:throw new Error(`Unknown type ${c}`)}}else{const c=new Array(s.length);a[o]=c;for(let l=0;l<s.length;l+=1){const d=s[l];d!==Rt&&(c[l]=r(d))}}else{const c={};a[o]=c;for(const l in s){const d=s[l];c[l]=r(d)}}return a[o]}return r(0)}const qe=new Set(["load","prerender","csr","ssr","trailingSlash","config"]);[...qe];const Tt=new Set([...qe]);[...Tt];function Nt(e){return e.filter(t=>t!=null)}class te{constructor(t,n){this.status=t,typeof n=="string"?this.body={message:n}:n?this.body=n:this.body={message:`Error: ${t}`}}toString(){return JSON.stringify(this.body)}}class He{constructor(t,n){this.status=t,this.location=n}}class ve extends Error{constructor(t,n,a){super(a),this.status=t,this.text=n}}const Ot="x-sveltekit-invalidated",jt="x-sveltekit-trailing-slash";function W(e){return e instanceof te||e instanceof ve?e.status:500}function Dt(e){return e instanceof ve?e.text:"Internal Error"}const U=De(Ce)??{},G=De($e)??{},$t=history.pushState,we=history.replaceState,L={url:xe({}),page:xe({}),navigating:_e(null),updated:At()};function be(e){U[e]=ye()}function Ct(e,t){let n=e+1;for(;U[n];)delete U[n],n+=1;for(n=t+1;G[n];)delete G[n],n+=1}function O(e){return location.href=e.href,new Promise(()=>{})}function Ue(){}let ne,he,z,I,ge,D;const Ee=[],X=[];let x=null;const Be=[],Vt=[];let V=[],m={branch:[],error:null,url:null},ke=!1,Z=!1,Te=!0,M=!1,$=!1,Ke=!1,ae=!1,re,v,A,k,j,ue;async function Xt(e,t,n){document.URL!==location.href&&(location.href=location.href),D=e,ne=wt(e),I=document.documentElement,ge=t,he=e.nodes[0],z=e.nodes[1],he(),z(),v=history.state?.[N],A=history.state?.[F],v||(v=A=Date.now(),we.call(history,{...history.state,[N]:v,[F]:A},""));const a=U[v];a&&(history.scrollRestoration="manual",scrollTo(a.x,a.y)),n?await Yt(ge,n):Bt(location.href,{replaceState:!0}),Kt()}async function Ft(){if(await(ue||=Promise.resolve()),!ue)return;ue=null;const e=se(m.url,!0);x=null;const t=j={},n=e&&await Ie(e);t===j&&(n&&(n.type==="redirect"?await Ae(new URL(n.location,m.url).href,{},1,t):(n.props.page!==void 0&&(k=n.props.page),re.$set(n.props))),Ee.length=0)}function Ye(e){X.some(t=>t?.snapshot)&&(G[e]=X.map(t=>t?.snapshot?.capture()))}function Je(e){G[e]?.forEach((t,n)=>{X[n]?.snapshot?.restore(t)})}function Ne(){be(v),Le(Ce,U),Ye(A),Le($e,G)}async function Ae(e,t,n,a){return K({type:"goto",url:Fe(e),keepfocus:t.keepFocus,noscroll:t.noScroll,replace_state:t.replaceState,state:t.state,redirect_count:n,nav_token:a,accept:()=>{t.invalidateAll&&(ae=!0)}})}async function Gt(e){return x={id:e.id,promise:Ie(e).then(t=>(t.type==="loaded"&&t.state.error&&(x=null),t))},x.promise}async function de(e){const t=ne.find(n=>n.exec(ze(e)));t&&await Promise.all([...t.layouts,t.leaf].map(n=>n?.[1]()))}function We(e,t){m=e.state;const n=document.querySelector("style[data-sveltekit]");n&&n.remove(),k=e.props.page,re=new D.root({target:t,props:{...e.props,stores:L,components:X},hydrate:!0}),Je(A);const a={from:null,to:{params:m.params,route:{id:m.route?.id??null},url:new URL(location.href)},willUnload:!1,type:"enter",complete:Promise.resolve()};V.forEach(r=>r(a)),Z=!0}async function Q({url:e,params:t,branch:n,status:a,error:r,route:o,form:i}){let s="never";if(S&&(e.pathname===S||e.pathname===S+"/"))s="always";else for(const f of n)f?.slash!==void 0&&(s=f.slash);e.pathname=at(e.pathname,s),e.search=e.search;const c={type:"loaded",state:{url:e,params:t,branch:n,error:r,route:o},props:{constructors:Nt(n).map(f=>f.node.component),page:k}};i!==void 0&&(c.props.form=i);let l={},d=!k,g=0;for(let f=0;f<Math.max(n.length,m.branch.length);f+=1){const p=n[f],h=m.branch[f];p?.data!==h?.data&&(d=!0),p&&(l={...l,...p.data},d&&(c.props[`data_${g}`]=l),g+=1)}return(!m.url||e.href!==m.url.href||m.error!==r||i!==void 0&&i!==k.form||d)&&(c.props.page={error:r,params:t,route:{id:o?.id??null},state:{},status:a,url:new URL(e),form:i??null,data:d?l:k.data}),c}async function Se({loader:e,parent:t,url:n,params:a,route:r,server_data_node:o}){let i=null,s=!0;const c={dependencies:new Set,params:new Set,parent:!1,route:!1,url:!1,search_params:new Set},l=await e();if(l.universal?.load){let d=function(...u){for(const f of u){const{href:p}=new URL(f,n);c.dependencies.add(p)}};const g={route:new Proxy(r,{get:(u,f)=>(s&&(c.route=!0),u[f])}),params:new Proxy(a,{get:(u,f)=>(s&&c.params.add(f),u[f])}),data:o?.data??null,url:it(n,()=>{s&&(c.url=!0)},u=>{s&&c.search_params.add(u)}),async fetch(u,f){let p;u instanceof Request?(p=u.url,f={body:u.method==="GET"||u.method==="HEAD"?void 0:await u.blob(),cache:u.cache,credentials:u.credentials,headers:u.headers,integrity:u.integrity,keepalive:u.keepalive,method:u.method,mode:u.mode,redirect:u.redirect,referrer:u.referrer,referrerPolicy:u.referrerPolicy,signal:u.signal,...f}):p=u;const h=new URL(p,n);return s&&d(h.href),h.origin===n.origin&&(p=h.href.slice(n.origin.length)),Z?ht(p,h.href,f):pt(p,f)},setHeaders:()=>{},depends:d,parent(){return s&&(c.parent=!0),t()},untrack(u){s=!1;try{return u()}finally{s=!0}}};i=await l.universal.load.call(null,g)??null}return{node:l,loader:e,server:o,universal:l.universal?.load?{type:"data",data:i,uses:c}:null,data:i??o?.data??null,slash:l.universal?.trailingSlash??o?.slash}}function Oe(e,t,n,a,r,o){if(ae)return!0;if(!r)return!1;if(r.parent&&e||r.route&&t||r.url&&n)return!0;for(const i of r.search_params)if(a.has(i))return!0;for(const i of r.params)if(o[i]!==m.params[i])return!0;for(const i of r.dependencies)if(Ee.some(s=>s(new URL(i))))return!0;return!1}function Re(e,t){return e?.type==="data"?e:e?.type==="skip"?t??null:null}function Mt(e,t){if(!e)return new Set(t.searchParams.keys());const n=new Set([...e.searchParams.keys(),...t.searchParams.keys()]);for(const a of n){const r=e.searchParams.getAll(a),o=t.searchParams.getAll(a);r.every(i=>o.includes(i))&&o.every(i=>r.includes(i))&&n.delete(a)}return n}async function Ie({id:e,invalidating:t,url:n,params:a,route:r}){if(x?.id===e)return x.promise;const{errors:o,layouts:i,leaf:s}=r,c=[...i,s];o.forEach(_=>_?.().catch(()=>{})),c.forEach(_=>_?.[1]().catch(()=>{}));let l=null;const d=m.url?e!==m.url.pathname+m.url.search:!1,g=m.route?r.id!==m.route.id:!1,u=Mt(m.url,n);let f=!1;const p=c.map((_,y)=>{const w=m.branch[y],b=!!_?.[0]&&(w?.loader!==_[1]||Oe(f,g,d,u,w.server?.uses,a));return b&&(f=!0),b});if(p.some(Boolean)){try{l=await Qe(n,p)}catch(_){return oe({status:W(_),error:await q(_,{url:n,params:a,route:{id:r.id}}),url:n,route:r})}if(l.type==="redirect")return l}const h=l?.nodes;let R=!1;const E=c.map(async(_,y)=>{if(!_)return;const w=m.branch[y],b=h?.[y];if((!b||b.type==="skip")&&_[1]===w?.loader&&!Oe(R,g,d,u,w.universal?.uses,a))return w;if(R=!0,b?.type==="error")throw b;return Se({loader:_[1],url:n,params:a,route:r,parent:async()=>{const ie={};for(let ce=0;ce<y;ce+=1)Object.assign(ie,(await E[ce])?.data);return ie},server_data_node:Re(b===void 0&&_[0]?{type:"skip"}:b??null,_[0]?w?.server:void 0)})});for(const _ of E)_.catch(()=>{});const P=[];for(let _=0;_<c.length;_+=1)if(c[_])try{P.push(await E[_])}catch(y){if(y instanceof He)return{type:"redirect",location:y.location};let w=W(y),b;if(h?.includes(y))w=y.status??w,b=y.error;else if(y instanceof te)b=y.body;else{if(await L.updated.check())return await O(n);b=await q(y,{params:a,url:n,route:{id:r.id}})}const B=await qt(_,P,o);return B?await Q({url:n,params:a,branch:P.slice(0,B.idx).concat(B.node),status:w,error:b,route:r}):await Ze(n,{id:r.id},b,w)}else P.push(void 0);return await Q({url:n,params:a,branch:P,status:200,error:null,route:r,form:t?void 0:null})}async function qt(e,t,n){for(;e--;)if(n[e]){let a=e;for(;!t[a];)a-=1;try{return{idx:a+1,node:{node:await n[e](),loader:n[e],data:{},server:null,universal:null}}}catch{continue}}}async function oe({status:e,error:t,url:n,route:a}){const r={};let o=null;if(D.server_loads[0]===0)try{const l=await Qe(n,[!0]);if(l.type!=="data"||l.nodes[0]&&l.nodes[0].type!=="data")throw 0;o=l.nodes[0]??null}catch{(n.origin!==H||n.pathname!==location.pathname||ke)&&await O(n)}const s=await Se({loader:he,url:n,params:r,route:a,parent:()=>Promise.resolve({}),server_data_node:Re(o)}),c={node:await z(),loader:z,universal:null,server:null,data:null};return await Q({url:n,params:r,branch:[s,c],status:e,error:t,route:null})}function se(e,t){if(!e||ee(e,S))return;let n;try{n=D.hooks.reroute({url:new URL(e)})??e.pathname}catch{return}const a=ze(n);for(const r of ne){const o=r.exec(a);if(o)return{id:e.pathname+e.search,invalidating:t,route:r,params:ot(o),url:e}}}function ze(e){return rt(e.slice(S.length)||"/")}function Xe({url:e,type:t,intent:n,delta:a}){let r=!1;const o=tt(m,n,e,t);a!==void 0&&(o.navigation.delta=a);const i={...o.navigation,cancel:()=>{r=!0,o.reject(new Error("navigation cancelled"))}};return M||Be.forEach(s=>s(i)),r?null:o}async function K({type:e,url:t,popped:n,keepfocus:a,noscroll:r,replace_state:o,state:i={},redirect_count:s=0,nav_token:c={},accept:l=Ue,block:d=Ue}){const g=se(t,!1),u=Xe({url:t,type:e,delta:n?.delta,intent:g});if(!u){d();return}const f=v,p=A;l(),M=!0,Z&&L.navigating.set(u.navigation),j=c;let h=g&&await Ie(g);if(!h){if(ee(t,S))return await O(t);h=await Ze(t,{id:null},await q(new ve(404,"Not Found",`Not found: ${t.pathname}`),{url:t,params:{},route:{id:null}}),404)}if(t=g?.url||t,j!==c)return u.reject(new Error("navigation aborted")),!1;if(h.type==="redirect")if(s>=20)h=await oe({status:500,error:await q(new Error("Redirect loop"),{url:t,params:{},route:{id:null}}),url:t,route:{id:null}});else return Ae(new URL(h.location,t).href,{},s+1,c),!1;else h.props.page.status>=400&&await L.updated.check()&&await O(t);if(Ee.length=0,ae=!1,be(f),Ye(p),h.props.page.url.pathname!==t.pathname&&(t.pathname=h.props.page.url.pathname),i=n?n.state:i,!n){const _=o?0:1,y={[N]:v+=_,[F]:A+=_,[Ve]:i};(o?we:$t).call(history,y,"",t),o||Ct(v,A)}if(x=null,h.props.page.state=i,Z){m=h.state,h.props.page&&(h.props.page.url=t);const _=(await Promise.all(Vt.map(y=>y(u.navigation)))).filter(y=>typeof y=="function");if(_.length>0){let y=function(){V=V.filter(w=>!_.includes(w))};_.push(y),callbacks.after_navigate.push(..._)}re.$set(h.props),Ke=!0}else We(h,ge);const{activeElement:R}=document;await nt();const E=n?n.scroll:r?ye():null;if(Te){const _=t.hash&&document.getElementById(decodeURIComponent(t.hash.slice(1)));E?scrollTo(E.x,E.y):_?_.scrollIntoView():scrollTo(0,0)}const P=document.activeElement!==R&&document.activeElement!==document.body;!a&&!P&&Jt(),Te=!0,h.props.page&&(k=h.props.page),M=!1,e==="popstate"&&Je(A),u.fulfil(void 0),V.forEach(_=>_(u.navigation)),L.navigating.set(null)}async function Ze(e,t,n,a){return e.origin===H&&e.pathname===location.pathname&&!ke?await oe({status:a,error:n,url:e,route:t}):await O(e)}function Ht(){let e;I.addEventListener("mousemove",o=>{const i=o.target;clearTimeout(e),e=setTimeout(()=>{a(i,2)},20)});function t(o){a(o.composedPath()[0],1)}I.addEventListener("mousedown",t),I.addEventListener("touchstart",t,{passive:!0});const n=new IntersectionObserver(o=>{for(const i of o)i.isIntersecting&&(de(i.target.href),n.unobserve(i.target))},{threshold:0});function a(o,i){const s=Me(o,I);if(!s)return;const{url:c,external:l,download:d}=pe(s,S);if(l||d)return;const g=J(s);if(!g.reload)if(i<=g.preload_data){const u=se(c,!1);u&&Gt(u)}else i<=g.preload_code&&de(c.pathname)}function r(){n.disconnect();for(const o of I.querySelectorAll("a")){const{url:i,external:s,download:c}=pe(o,S);if(s||c)continue;const l=J(o);l.reload||(l.preload_code===Y.viewport&&n.observe(o),l.preload_code===Y.eager&&de(i.pathname))}}V.push(r),r()}function q(e,t){if(e instanceof te)return e.body;const n=W(e),a=Dt(e);return D.hooks.handleError({error:e,event:t,status:n,message:a})??{message:a}}function Bt(e,t={}){return e=Fe(e),e.origin!==H?Promise.reject(new Error("goto: invalid URL")):Ae(e,t,0)}function Zt(){return ae=!0,Ft()}function Kt(){history.scrollRestoration="manual",addEventListener("beforeunload",t=>{let n=!1;if(Ne(),!M){const a=tt(m,void 0,null,"leave"),r={...a.navigation,cancel:()=>{n=!0,a.reject(new Error("navigation cancelled"))}};Be.forEach(o=>o(r))}n?(t.preventDefault(),t.returnValue=""):history.scrollRestoration="auto"}),addEventListener("visibilitychange",()=>{document.visibilityState==="hidden"&&Ne()}),navigator.connection?.saveData||Ht(),I.addEventListener("click",t=>{if(t.button||t.which!==1||t.metaKey||t.ctrlKey||t.shiftKey||t.altKey||t.defaultPrevented)return;const n=Me(t.composedPath()[0],I);if(!n)return;const{url:a,external:r,target:o,download:i}=pe(n,S);if(!a)return;if(o==="_parent"||o==="_top"){if(window.parent!==window)return}else if(o&&o!=="_self")return;const s=J(n);if(!(n instanceof SVGAElement)&&a.protocol!==location.protocol&&!(a.protocol==="https:"||a.protocol==="http:")||i)return;if(r||s.reload){Xe({url:a,type:"link"})?M=!0:t.preventDefault();return}const[l,d]=a.href.split("#");if(d!==void 0&&l===le(location)){const[,g]=m.url.href.split("#");if(g===d){t.preventDefault(),d===""||d==="top"&&n.ownerDocument.getElementById("top")===null?window.scrollTo({top:0}):n.ownerDocument.getElementById(d)?.scrollIntoView();return}if($=!0,be(v),e(a),!s.replace_state)return;$=!1}t.preventDefault(),K({type:"link",url:a,keepfocus:s.keepfocus,noscroll:s.noscroll,replace_state:s.replace_state??a.href===location.href})}),I.addEventListener("submit",t=>{if(t.defaultPrevented)return;const n=HTMLFormElement.prototype.cloneNode.call(t.target),a=t.submitter;if((a?.formMethod||n.method)!=="get")return;const o=new URL(a?.hasAttribute("formaction")&&a?.formAction||n.action);if(ee(o,S))return;const i=t.target,s=J(i);if(s.reload)return;t.preventDefault(),t.stopPropagation();const c=new FormData(i),l=a?.getAttribute("name");l&&c.append(l,a?.getAttribute("value")??""),o.search=new URLSearchParams(c).toString(),K({type:"form",url:o,keepfocus:s.keepfocus,noscroll:s.noscroll,replace_state:s.replace_state??o.href===location.href})}),addEventListener("popstate",async t=>{if(t.state?.[N]){const n=t.state[N];if(j={},n===v)return;const a=U[n],r=t.state[Ve]??{},o=new URL(t.state[kt]??location.href),i=t.state[F],s=le(location)===le(m.url);if(i===A&&(Ke||s)){e(o),U[v]=ye(),a&&scrollTo(a.x,a.y),r!==k.state&&(k={...k,state:r},re.$set({page:k})),v=n;return}const l=n-v;await K({type:"popstate",url:o,popped:{state:r,scroll:a,delta:l},accept:()=>{v=n,A=i},block:()=>{history.go(-l)},nav_token:j})}else if(!$){const n=new URL(location.href);e(n)}}),addEventListener("hashchange",()=>{$&&($=!1,we.call(history,{...history.state,[N]:++v,[F]:A},"",location.href))});for(const t of document.querySelectorAll("link"))t.rel==="icon"&&(t.href=t.href);addEventListener("pageshow",t=>{t.persisted&&L.navigating.set(null)});function e(t){m.url=t,L.page.set({...k,url:t}),L.page.notify()}}async function Yt(e,{status:t=200,error:n,node_ids:a,params:r,route:o,data:i,form:s}){ke=!0;const c=new URL(location.href);({params:r={},route:o={id:null}}=se(c,!1)||{});let l;try{const d=a.map(async(f,p)=>{const h=i[p];return h?.uses&&(h.uses=et(h.uses)),Se({loader:D.nodes[f],url:c,params:r,route:o,parent:async()=>{const R={};for(let E=0;E<p;E+=1)Object.assign(R,(await d[E]).data);return R},server_data_node:Re(h)})}),g=await Promise.all(d),u=ne.find(({id:f})=>f===o.id);if(u){const f=u.layouts;for(let p=0;p<f.length;p++)f[p]||g.splice(p,0,void 0)}l=await Q({url:c,params:r,branch:g,status:t,error:n,form:s,route:u??null})}catch(d){if(d instanceof He){await O(new URL(d.location,location.href));return}l=await oe({status:W(d),error:await q(d,{url:c,params:r,route:o}),url:c,route:o})}l.props.page&&(l.props.page.state={}),We(l,e)}async function Qe(e,t){const n=new URL(e);n.pathname=ft(e.pathname),e.pathname.endsWith("/")&&n.searchParams.append(jt,"1"),n.searchParams.append(Ot,t.map(r=>r?"1":"0").join(""));const a=await je(n.href);if(!a.ok){let r;throw a.headers.get("content-type")?.includes("application/json")?r=await a.json():a.status===404?r="Not Found":a.status===500&&(r="Internal Error"),new te(a.status,r)}return new Promise(async r=>{const o=new Map,i=a.body.getReader(),s=new TextDecoder;function c(d){return Ut(d,{Promise:g=>new Promise((u,f)=>{o.set(g,{fulfil:u,reject:f})})})}let l="";for(;;){const{done:d,value:g}=await i.read();if(d&&!l)break;for(l+=!g&&l?`
`:s.decode(g,{stream:!0});;){const u=l.indexOf(`
`);if(u===-1)break;const f=JSON.parse(l.slice(0,u));if(l=l.slice(u+1),f.type==="redirect")return r(f);if(f.type==="data")f.nodes?.forEach(p=>{p?.type==="data"&&(p.uses=et(p.uses),p.data=c(p.data))}),r(f);else if(f.type==="chunk"){const{id:p,data:h,error:R}=f,E=o.get(p);o.delete(p),R?E.reject(c(R)):E.fulfil(c(h))}}}})}function et(e){return{dependencies:new Set(e?.dependencies??[]),params:new Set(e?.params??[]),parent:!!e?.parent,route:!!e?.route,url:!!e?.url,search_params:new Set(e?.search_params??[])}}function Jt(){const e=document.querySelector("[autofocus]");if(e)e.focus();else{const t=document.body,n=t.getAttribute("tabindex");t.tabIndex=-1,t.focus({preventScroll:!0,focusVisible:!1}),n!==null?t.setAttribute("tabindex",n):t.removeAttribute("tabindex");const a=getSelection();if(a&&a.type!=="None"){const r=[];for(let o=0;o<a.rangeCount;o+=1)r.push(a.getRangeAt(o));setTimeout(()=>{if(a.rangeCount===r.length){for(let o=0;o<a.rangeCount;o+=1){const i=r[o],s=a.getRangeAt(o);if(i.commonAncestorContainer!==s.commonAncestorContainer||i.startContainer!==s.startContainer||i.endContainer!==s.endContainer||i.startOffset!==s.startOffset||i.endOffset!==s.endOffset)return}a.removeAllRanges()}})}}}function tt(e,t,n,a){let r,o;const i=new Promise((c,l)=>{r=c,o=l});return i.catch(()=>{}),{navigation:{from:{params:e.params,route:{id:e.route?.id??null},url:e.url},to:n&&{params:t?.params??null,route:{id:t?.route?.id??null},url:n},willUnload:!t,type:a,complete:i},fulfil:r,reject:o}}export{He as R,Xt as a,Bt as g,Zt as i,L as s};
