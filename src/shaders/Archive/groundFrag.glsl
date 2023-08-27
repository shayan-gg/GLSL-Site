varying vec3 vertexPosition;
varying vec2 vertexUV;
// #include <fog_pars_vertex>

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
    // f  = 0.5000*noise( uv ); uv = m*uv;
    // f += 0.2500*noise( uv ); uv = m*uv;
    // f += 0.1250*noise( uv ); uv = m*uv;
    // f += 0.0625*noise( uv ); uv = m*uv;
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
    // #include <fog_vertex>
    vec2 roadM;
    float scale = 200.0;
    float scaleDeg = scale * 3.14;
    float epsillion = .8;
    float epsillionSW = .9;
    float epsillionSWTex = .99;
    vec3 col = vec3(1.0, 0.7, 0.3);
    vec2 vUV = vertexUV;
    vUV += vec2(5.0, 5.0);

    float xd = sin(vUV.x * scaleDeg);
    float yd = sin(vUV.y * scaleDeg);

    roadM.x = step (xd, epsillion);
    roadM.y = step (yd, epsillion);
    float roadMask = roadM.x * roadM.y;

    float sideWalk = step(xd, epsillionSW) * step(yd, epsillionSW);
    float sideWalkTex = step(sin(vUV.x*10000.), .99) * step(sin(vUV.y*10000.), .5); 

    float road = simplexNoise(vertexUV, 2, 8000.0) * .1;
    road = mix( road, 0.9, sideWalk );

    //col = vec3(road);
    float noise = simplexNoise(vertexUV, 6, 1000.0);

    vec3 grass = mix(vec3(road), vec3(0.2, noise, 0.1), roadMask);
    col = vec3(grass);

    gl_FragColor = vec4(vertexUV, 0., 1.0);
}