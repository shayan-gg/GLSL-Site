uniform float time;
uniform vec2 key;
uniform float aspect;
uniform vec4 value;
uniform vec3 color;
uniform vec2 mouse;
uniform vec2 mouse1;
uniform float EPSv;
uniform float charArr[25];
uniform float charLength;
uniform sampler2D textTex;

varying vec3 vertexPosition;
varying vec2 vertexUV;
varying vec2 uvReal;

float random(vec2 st){
    return fract(sin(dot(st, vec2(12.9898,78.233)))* 43758.5453123);
}

vec2 hash( vec2 p ) // replace this by something better
{
	p = vec2( dot(p,vec2(127.1,311.7)), dot(p,vec2(269.5,183.3)) );
	return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}

float noise( in vec2 p )
{
    const float K1 = 0.366025404; // (sqrt(3)-1)/2;
    const float K2 = 0.211324865; // (3-sqrt(3))/6;

	vec2  i = floor( p + (p.x+p.y)*K1 );
    vec2  a = p - i + (i.x+i.y)*K2;
    float m = step(a.y,a.x); 
    vec2  o = vec2(m,1.0-m);
    vec2  b = a - o + K2;
	vec2  c = a - 1.0 + 2.0*K2;
    vec3  h = max( 0.5-vec3(dot(a,a), dot(b,b), dot(c,c) ), 0.0 );
	vec3  n = h*h*h*h*vec3( dot(a,hash(i+0.0)), dot(b,hash(i+o)), dot(c,hash(i+1.0)));
    return dot( n, vec3(70.0) );
}

float simplexNoise(in vec2 uv, int o, float s)
{
    float f = 0.0;
    uv *= s;
    mat2 m = mat2( 1.6,  1.2, -1.2,  1.6 );
    float j = .5;
    for(int i = 0; i < o; i++)
    {
        f += j*noise( uv ); uv = m*uv;
        j/=2.;
    }
    f += .5;
    return f;
}

void main()
{
    uvReal = uv;
    vertexPosition = position;
    vec3 vPos = position;
    vec2 vUV = vec2((uv.x * aspect) - (aspect/2. - .5), uv.y);
    vUV = vec2((vUV *2. - 1.));
    
    // vUV = smoothstep(0., 1., vUV);
    //vPos.z = simplexNoise(uv, 7, 4.) * 100.;

    vertexUV= vUV;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}