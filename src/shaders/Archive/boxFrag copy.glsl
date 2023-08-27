// Uniforms, Varings and Variables
    uniform float   time;
    uniform vec2    key;
    uniform vec4    value;
    uniform vec3    color;
    uniform vec2    mouse;
    uniform vec2    mouse1;
    uniform float   EPSv;

    varying vec3    vertexPosition;
    varying vec2    vertexUV;
    // #include <fog_pars_vertex>

    #define NEAR_CLIPPING_PLANE         0.1
    #define FAR_CLIPPING_PLANE          100.0
    #define NUMBER_OF_MARCH_STEPS       4000
    #define EPSILON                     0.01
    #define DISTANCE_BIAS               0.1
    #define PI                          3.14159265
    #define _E =                        0.00005

// Functions
float random(vec2 st){
    return fract(sin(dot(st, vec2(12.9898,78.233)))* 43758.5453123); }

vec2 hash( vec2 p ) { // replace this by something better
	p = vec2( dot(p,vec2(127.1,311.7)), dot(p,vec2(269.5,183.3)) );
	return -1.0 + 2.0*fract(sin(p)*43758.5453123); }

float noise( in vec2 p ) {
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
    return dot( n, vec3(70.0) ); }

float simplexNoise(in vec2 uv, int o, float s) {
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
    return f; }

float sdSphere(vec3 p, float s) { 
    return length(p) - s; }
float sdPlane( vec3 p, vec3 n, float h ) {
  // n must be normalized
  return dot(p,n) + h;}

float fmod(float a, float b) {
    if(a<0.0)
    {
        return b - mod(abs(a), b);
    }
    return mod(a, b); }

vec2 smin( float a, float b, float k ) {
    float h =  max( k-abs(a-b), 0.0 )/k;
    float m = h*h*0.5;
    float s = m*k*(1.0/2.0);
    return (a<b) ? vec2(a-s,m) : vec2(b-s,1.0-m); }

vec4 smoothUnion( vec4 d1, vec4 d2, float k ) {
    float h = clamp( 0.5 + 0.5*(d2.x-d1.x)/k, 0.0, 1.0 );
    return mix( d2, d1, h ) - k*h*(1.0-h); }

float sdS(vec3 p, float s) {
    //p= vec3(0.,, p.z);
    p = vec3(p.x-mouse.x*2., p.y+mouse.y*2., p.z);
    vec2 tc = value.xy;
    float ra = value.z;
    float rb = value.w;
    vec2 sc = tc;

    // vec2 q = vec2(length(p.xy)-ra,p.z);
    // return length(q)-rb;
    float an = value.x;
    sc = vec2(sin(an),cos(an));
    p.x += sin(p.y+time*tc.y);
    p.x = abs(p.x);
    // p.y += tc.y; // height
    float k = (sc.y*p.x > sc.x*p.y) ? dot(p.xy,sc) : length(p.xy);
    //float k = (sc.y*p.x > sc.x*p.y) ? dot(p.xy,sc) : length(p.xy);
    return sqrt( dot(p,p) + ra*ra - 2.0*ra*k ) - rb; }

// Raymarching
vec4 scene(vec3 position) {
    //Define Colors
    vec3 
        _White     = vec3(1.0, 1.0, 1.0),
        _Black     = vec3(0.0, 0.0, 0.0),
        _Red       = vec3(1.0, 0.4314, 0.3333),
        _Green     = vec3(0.0, 0.9882, 0.4941),
        _Blue      = vec3(0.0, 0.0, 1.0),
        _Cyan      = vec3(0.0, 1.0, 1.0),
        _Yellow    = vec3(1.0, 1.0, 0.0),
        _Megenta   = vec3(1.0, 0.0, 1.0);

    vec3 groundPos = vec3(0., 1., -2.) + position;
    float distance = sdPlane(groundPos, vec3(0., 1., 0.), 0.1);
    
    // leaving the shape as is, creating various results. So let's tile in X with a sine wave offset in Y!
    vec3 sphere_pos = position;
    // When tiling by any tile size, offset your position by half the tile size like this!
    sphere_pos.x = fract(sphere_pos.x + 0.5) - 0.5; // fract() is mod(v, 1.0) or in mathemathical terms x % 1.0
    sphere_pos.z = fmod(sphere_pos.z + 1.0, 2.0) - 1.0; // example without fract
    // now let's animate the height!
    sphere_pos.y += sin(position.x + time) * 0.35; //add time to animate, multiply by samll number to reduce amplitude
    sphere_pos.y += cos(position.z + time);
    float distance2 = sdSphere(sphere_pos, 0.05);

    ////
    vec3 spsPos = vec3(0., -0.3, -4.) + position;
    float distance3 = sdS(spsPos, 0.5);

    vec4 //Merge all SDFs
        d = smoothUnion(vec4(distance, _Green), vec4(distance2, _White), 0.5);
        d = smoothUnion(vec4(d), vec4(distance3, vec3(_White)), 0.5);

    return d; }

vec4 raymarch(vec3 position, vec3 direction) {
    /*
	This function iteratively analyses the scene to approximate the closest ray-hit
	*/
    // We track how far we have moved so we can reconstruct the end-point later
    float total_distance = NEAR_CLIPPING_PLANE;
    for(int i = 0 ; i < NUMBER_OF_MARCH_STEPS ; ++i)
    {
        vec4 result = scene(position + direction * total_distance);
        // If our ray is very close to a surface we assume we hit it
        // and return it's material
        if(result.x < EPSILON)
        {
            return vec4(total_distance, result.yzw);
        }
        
        // Accumulate distance traveled
        // The result.x contains closest distance to the world
        // so we can be sure that if we move it that far we will not accidentally
        // end up inside an object. Due to imprecision we do increase the distance
        // by slightly less... it avoids normal errors especially.
        total_distance += result.x * DISTANCE_BIAS;
        
        // Stop if we are headed for infinity
        if(total_distance > FAR_CLIPPING_PLANE)
            break;
    }
    // By default we return no material and the furthest possible distance
    // We only reach this point if we didn't get close to a surface during the loop above
    //return vec4(FAR_CLIPPING_PLANE, discard);
    discard;}
vec3 normal1(vec3 ray_hit_position, float smoothness) {
    smoothness = 0.001;
	vec3 n;
	vec2 dn = vec2(smoothness, 0.0);
	n.x	= scene(ray_hit_position + dn.xyy).x - scene(ray_hit_position - dn.xyy).x;
	n.y	= scene(ray_hit_position + dn.yxy).x - scene(ray_hit_position - dn.yxy).x;
	n.z	= scene(ray_hit_position + dn.yyx).x - scene(ray_hit_position - dn.yyx).x;
	return normalize(n); }
float map(vec3 p) {
    return sdSphere(p, 0.5); }
vec3 normal( in vec3 pos, float smoothness ) {
    //vec2 e = vec2(0.5773,-0.5773);
    vec2 e = vec2(-10.,200.);
    const float eps = 0.01;
    return normalize( e.xyy * scene( pos + e.xyy* eps ).x + 
					  e.yyx * scene( pos + e.yyx* eps ).x + 
					  e.yxy * scene( pos + e.yxy* eps ).x + 
					  e.xxx * scene( pos + e.xxx* eps ).x ); }
    

// Main Function
void main()
{
    // #include <fog_vertex>

    vec3 direction = normalize(vec3(vertexUV, 2.5));
    // if you rotate the direction with a rotatin matrix you can turn the camera too!
    
    vec3 camera_origin = vec3(key.y, 0.0, key.x); // you can move the camera here
    
    vec4 result = raymarch(camera_origin, direction); // this raymarches the scene
    
    // arbitrary fog to hide artifacts near the far plane
    // float fog = pow(1.0 / (1.0 + result.x), 0.45);
    
    // now let's pick a color
    //vec3 materialColor = vec3(0.0, 0.0, 0.0);
    vec3 materialColor = result.yzw;
    
    // We can reconstruct the intersection point using the distance and original ray
    vec3 intersection = camera_origin + direction * result.x;
    
    // The normals can be retrieved in a fast way by taking samples close to the end-result sample their resulting distances to the world are used to see how the surface curves in 3D
    vec3 nrml = normal(intersection, 0.01);
    // vec3 nrml = calcNormal(intersection);
    
    // Lambert lighting is the dot product of a directional light and the normal
    vec3 light_dir = normalize(vec3(0.0, 1.0, 0.0));
   	float diffuse = dot(light_dir, nrml);
    diffuse = max(0.0, diffuse);
    
    // Combine ambient light and diffuse lit directional light
    vec3 light_color = vec3(1.4, 1.2, 0.7);
    vec3 ambient_color = vec3(0.2, 0.45, 0.6);
    vec3 diffuseLit = materialColor * (diffuse * light_color + ambient_color);
    
    gl_FragColor = vec4(vec3(diffuseLit), 1.);
    // gl_FragColor = vec4(value, 0., diffuse);
}