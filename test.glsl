#define specular

DirLamp lamps[3];

vec3 campos = vec3(0., 0., -9.);
vec3 camdir = vec3(0., 0., 1.);
float fov = 4.7;

const vec3 ambientColor = vec3(1.);
const float ambientint = 0.26;
const vec3 speccolor = vec3(0.9, 0.95, 1.);
const float specint = 0.43;
const float specshin = 3.2;

const float globalLampsInt = 0.4;

const float normdelta = 0.0025;
const float maxdist = 80.;

const float textDepth = 0.1;
const float textBevel = 0.04;
const float objscale = 0.055;
const vec2 textScale = vec2(1., 1.1);
const vec2 charSpacingFac = vec2(.55, .95);

float flashint = 1.2;
float flashpos0 = -0.6;
float flashpos;

const float objSpacing = 18.;
const float objSpeed = 3.;
const float initTime = 0.;

vec3 sideColors[7];
vec3 faceColors[7];
vec3 bevelColors[7];

float zPos;
float zRot;
float time2;

#define _Tambako _T _a _m _b _a _k _o
#define _theJaguar _t _h _e _SP _J _a _g _u _a _r
#define _presents _p _r _e _s _e _n _t _s
#define _acoolshader _a _SP _c _o _o _l _SP _s _h _a _d _e _r
#define _poweredby _p _o _w _e _r _e _d _SP _b _y _PT _PT _PT
#define _shadertoy _S _h _a _d _e _r _t _o _y

#define OBJ_TAMBAKO         1
#define OBJ_THE_JAGUAR      2
#define OBJ_PRESENTS        3
#define OBJ_A_COOL_SHADER   4
#define OBJ_POWERED_BY      5
#define OBJ_SHADERTOY       6 

int chi;
int nbchars;

// Antialias. Change from 1 to 2 or more AT YOUR OWN RISK! It may CRASH your browser while compiling!
//#define antialias
const float aawidth = 0.8;
const int aasamples = 2;

void init()
{
  sideColors[OBJ_TAMBAKO] = vec3(0.9, 0.55, 0.45);
  sideColors[OBJ_THE_JAGUAR] = vec3(0.9, 0.55, 0.45);;
  sideColors[OBJ_PRESENTS] = vec3(0.75, 0.8, 0.85);
  sideColors[OBJ_A_COOL_SHADER] = vec3(0.75, 0.8, 0.85);
  sideColors[OBJ_POWERED_BY] = vec3(0.75, 0.8, 0.85);
  sideColors[OBJ_SHADERTOY] = vec3(0.75, 0.8, 0.85);
    
  faceColors[OBJ_TAMBAKO] = vec3(0.9, 0.75, 0.5);
  faceColors[OBJ_THE_JAGUAR] = vec3(0.9, 0.75, 0.5);
  faceColors[OBJ_PRESENTS] = vec3(0.75, 0.8, 0.85);
  faceColors[OBJ_A_COOL_SHADER] = vec3(0.75, 0.8, 0.85);
  faceColors[OBJ_POWERED_BY] = vec3(0.75, 0.8, 0.85);
  faceColors[OBJ_SHADERTOY] = vec3(0.95, 0.3, 0.2);
    
  bevelColors[OBJ_TAMBAKO] = vec3(1., 1., 1.);
  bevelColors[OBJ_THE_JAGUAR] = vec3(1., 1., 1.);
  bevelColors[OBJ_PRESENTS] = vec3(0.75, 0.8, 0.85);
  bevelColors[OBJ_A_COOL_SHADER] = vec3(0.75, 0.8, 0.85);
  bevelColors[OBJ_POWERED_BY] = vec3(0.75, 0.8, 0.85);
  bevelColors[OBJ_SHADERTOY] = vec3(1., 0., 0.);     
    
  lamps[0] = DirLamp(vec3(-10., 4.5, -10.), vec3(1., 1., 1.), 0.75);
  lamps[1] = DirLamp(vec3(12., -2.5, -4.), vec3(0.77, 0.87, 1.0), 0.5);
  lamps[2] = DirLamp(vec3(-9., -5., 4.), vec3(1.0, 0.6, 0.5), 0.4);    
    
  time2 = mod(iTime + initTime, 7.*objSpacing/objSpeed);
  zPos = -objSpacing*7.8 + 12.8*objSpacing*smoothstep(-6.2*objSpacing/objSpeed, 6.2*objSpacing/objSpeed, time2);
  zRot = 0.09*cos(12.*time2*objSpeed)*(smoothstep(6.1*objSpacing/objSpeed, 6.13*objSpacing/objSpeed, time2)*smoothstep(6.18*objSpacing/objSpeed, 6.15*objSpacing/objSpeed, time2));
  if (time2<6.*objSpacing/objSpeed)
     flashpos = flashpos0 - 5.2*clamp(smoothstep(flashpos0 - 4., flashpos0 + 4., mod(zPos, objSpacing)), 0.5, 1.) + 3.1;
  else
     flashpos = flashpos0;
}

// Union operation from iq
vec2 opU(vec2 d1, vec2 d2)
{
	return (d1.x<d2.x) ? d1 : d2;
}

vec2 rotateVec(vec2 vect, float angle)
{
    vec2 rv;
    rv.x = vect.x*cos(angle) + vect.y*sin(angle);
    rv.y = -vect.x*sin(angle) + vect.y*cos(angle);
    return rv;
}

float sdBox(vec3 p, vec3 radius)
{
    vec3 dist = abs(p) - radius;
    return min(max(dist.x, max(dist.y, dist.z)), 0.0) + length(max(dist, 0.0));
}

float getChar(vec2 uv, int ch)
{
    ch-= 127;
    vec2 uv2 = mod(uv, charSpacingFac*1./16.);
    uv2.y-= 0.5;
    vec2 offset = vec2(mod(float(ch-1), 16.)/16., -float(ch/16)/16.);
    vec2 pos = uv2 + offset + textScale*vec2((1.-charSpacingFac.x)/32., (1.-charSpacingFac.y)/32.);
    //return texture(iChannel0, pos).a;
    return textureLod(iChannel0, pos, 0.65).a;
}

float textTexture(vec2 uv, int defText)
{
   uv/= textScale;
   int idx = int(uv.x*16./charSpacingFac.x)+1000*int(uv.y*16./charSpacingFac.y); 
    
   int char = 32;
   int chi = 0;
    
   if (defText==OBJ_TAMBAKO) { _Tambako }
   if (defText==OBJ_THE_JAGUAR) { _theJaguar }
   if (defText==OBJ_PRESENTS) { _presents }
   if (defText==OBJ_A_COOL_SHADER) { _acoolshader }
   if (defText==OBJ_POWERED_BY) { _poweredby }
   if (defText==OBJ_SHADERTOY) { _shadertoy }
    
   return char==32?0.9:getChar(uv, char);
}

float map_text(vec3 pos, vec3 offset, float depth, float bevel, float bold, int defText)
{   
   if (defText==OBJ_TAMBAKO) nbchars = 7;
   if (defText==OBJ_THE_JAGUAR) nbchars = 10;
   if (defText==OBJ_PRESENTS) nbchars = 8;
   if (defText==OBJ_A_COOL_SHADER) nbchars = 13;
   if (defText==OBJ_POWERED_BY) nbchars = 13;
   if (defText==OBJ_SHADERTOY) nbchars = 9;    
    
   pos+= offset;
   vec2 uv = objscale*pos.xy + vec2(float(nbchars)*charSpacingFac.x*textScale.x/32., 0.025);
   float text = textTexture(uv, defText) - 0.5 - bold;
    
   text+= bevel*smoothstep(-depth + bevel*0.5, -depth - bevel*0.5, pos.z);
    
   float cropBox = sdBox(pos - vec3(0., 0.1, 0.), vec3(float(nbchars)*charSpacingFac.x*textScale.x/(objscale*32.), charSpacingFac.y*textScale.y/(objscale*33.), depth));
    
   return max(text, cropBox);
}

vec2 map(vec3 pos)
{
   vec3 posr = pos;
   posr.xy = rotateVec(posr.xy, zRot);
    
   float Tambako = map_text(posr, vec3(0., 0., zPos), textDepth, textBevel, 0., OBJ_TAMBAKO);
   float theJaguar = map_text(posr, vec3(0., 0., -1.*objSpacing + zPos), textDepth, textBevel, 0., OBJ_THE_JAGUAR);
   float presents = map_text(posr, vec3(0., 0., -2.*objSpacing + zPos), textDepth, textBevel, 0., OBJ_PRESENTS);
   float aCoolShader = map_text(posr, vec3(0., 0., -3.*objSpacing + zPos), textDepth, textBevel, 0., OBJ_A_COOL_SHADER);
   float poweredBy = map_text(posr, vec3(0., 0., -4.*objSpacing + zPos), textDepth, textBevel, 0., OBJ_POWERED_BY);
   float shadertoy = map_text(posr, vec3(0., 0., -5.*objSpacing + zPos), textDepth, textBevel, 0.02, OBJ_SHADERTOY);    
    
   vec2 res = vec2(Tambako, OBJ_TAMBAKO); 
   res = opU(res, vec2(theJaguar, OBJ_THE_JAGUAR));
   res = opU(res, vec2(presents, OBJ_PRESENTS));
   res = opU(res, vec2(aCoolShader, OBJ_A_COOL_SHADER));
   res = opU(res, vec2(poweredBy, OBJ_POWERED_BY));
   res = opU(res, vec2(shadertoy, OBJ_SHADERTOY));
    
   return res;
}

vec2 trace(vec3 cam, vec3 ray, float maxdist) 
{
    float t = 0.01;
    float objnr = 0.;
    vec3 pos;
    float dist;
    
  	for (int i = 0; i < 120; ++i)
    {
    	pos = ray*t + cam;
        vec2 res = map(pos);
        dist = res.x;
        if (dist>maxdist || abs(dist)<0.001)
            break;
        t+= dist*0.95;
        objnr = abs(res.y);
  	}
  	return vec2(t, objnr);
}

vec3 getNormal(vec3 pos, float e)
{  
    vec3 n = vec3(0.0);
    for( int i=0; i<4; i++ )
    {
        vec3 e2 = 0.5773*(2.0*vec3((((i+3)>>1)&1),((i>>1)&1),(i&1))-1.0);
        n += e2*map(pos + e*e2).x;
    }
    return normalize(n);
}

vec3 obj_color(vec3 norm, vec3 pos, float objnr)
{
    vec3 col = sideColors[int(objnr)];
    float zPos2 = pos.z + zPos - (objnr - 1.)*objSpacing;
    
    if (zPos2<-textDepth)
        col = faceColors[int(objnr)];    
    else if (zPos2<-textDepth + textBevel)
        col = bevelColors[int(objnr)];

    return col;
}

vec3 lampShading(DirLamp lamp, vec3 norm, vec3 pos, vec3 ocol, float objnr)
{
	vec3 pl = normalize(lamp.direction);
      
    // Diffuse shading
    vec3 col = globalLampsInt*ocol*lamp.color*lamp.intensity*smoothstep(-0.4, 1., dot(norm, pl));
    
    // Specular shading
    #ifdef specular
    if (dot(norm, lamp.direction) > 0.0)
        col+= globalLampsInt*col*ambientColor*ambientint + lamp.color*lamp.intensity*specint*pow(max(0.0, dot(reflect(pl, norm), normalize(pos - campos))), specshin);
    #endif
    
    col*= smoothstep(objSpacing*1.5, objSpacing*0.2, pos.z);
    
    return col;
}

vec3 lampsShading(vec3 norm, vec3 pos, vec3 ocol, float objnr)
{
    vec3 col = vec3(0.);
    for (int l=0; l<lamps.length(); l++)
        col+= lampShading(lamps[l], norm, pos, ocol, objnr);
    
    float ff = smoothstep(flashpos - 0.4, flashpos - 0.2, pos.z)*smoothstep(flashpos + 0.2, flashpos - 0.1, pos.z);
    col = mix(col, ocol*flashint, ff);
    
    return col;
}

// From https://www.shadertoy.com/view/lsSXzD, modified
vec3 GetCameraRayDir(vec2 vWindow, vec3 vCameraDir, float fov)
{
	vec3 vForward = normalize(vCameraDir);
	vec3 vRight = normalize(cross(vec3(0.0, 1.0, 0.0), vForward));
	vec3 vUp = normalize(cross(vForward, vRight));
    
	vec3 vDir = normalize(vWindow.x * vRight + vWindow.y * vUp + vForward * fov);

	return vDir;
}

RenderData trace0(vec3 tpos, vec3 ray)
{
   vec2 t = trace(tpos, ray, maxdist);
   float tx = t.x;
   vec3 col;
   float objnr = t.y;
    
   vec3 pos = tpos + tx*ray;
   vec3 norm;
   if (tx<maxdist*0.65)
   {
      norm = getNormal(pos, normdelta);

      // Coloring
      vec3 ocol = obj_color(norm, pos, objnr);
      
      // Shading
      col = lampsShading(norm, pos, ocol, objnr);
   }
    
   return RenderData(col, pos, norm, objnr);
}

vec4 render(vec2 fragCoord)
{    
  vec2 uv = fragCoord.xy / iResolution.xy; 
  uv = uv*2.0 - 1.0;
  uv.x*= iResolution.x / iResolution.y;

  vec3 ray = GetCameraRayDir(uv, camdir, fov);
    
  RenderData traceinf = trace0(campos, ray);
  vec3 col = traceinf.col;
    
  col*= smoothstep(6.9*objSpacing/objSpeed, 6.6*objSpacing/objSpeed, time2);
  col*= smoothstep(0., 0.15*objSpacing/objSpeed, time2);

  return vec4(col, 1.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{   
    init();
    
    // Antialiasing.
    #ifdef antialias
    vec4 vs = vec4(0.);
    for (int j=0;j<aasamples ;j++)
    {
       float oy = float(j)*aawidth/max(float(aasamples-1), 1.);
       for (int i=0;i<aasamples ;i++)
       {
          float ox = float(i)*aawidth/max(float(aasamples-1), 1.);
          vs+= render(fragCoord + vec2(ox, oy));
       }
    }
    fragColor = vs/vec4(aasamples*aasamples);
    #else
    fragColor = vec4(render(fragCoord));
    #endif
}