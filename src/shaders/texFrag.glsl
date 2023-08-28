// Uniforms, Varings and Variables
    uniform float   time;
    uniform vec2    key;
    uniform vec4    value;
    uniform vec3    color;
    uniform vec2    mouse;
    uniform vec2    mouse1;
    uniform float   EPSv;
    uniform float charArr[25];
    uniform float charLength;
    uniform sampler2D textTex;

    varying vec3    vertexPosition;
    varying vec2    vertexUV;
    varying vec2    uvReal;
    // #include <fog_pars_vertex>

    #define NEAR_CLIPPING_PLANE         0.1
    #define FAR_CLIPPING_PLANE          100.0
    #define NUMBER_OF_MARCH_STEPS       4000
    #define EPSILON                     0.1
    #define DISTANCE_BIAS               0.1
    #define PI                          3.14159265
    #define _E =                        0.005

// Hash
    float hash1( float n )
    {
        return fract( n*17.0*fract( n*0.3183099 ) );
    }
    float hash1( vec2 p )
    {
        p  = 50.0*fract( p*0.3183099 );
        return fract( p.x*p.y*(p.x+p.y) );
    }
    vec2 hash2( vec2 p )
    { // replace this by something better
        const vec2 k = vec2( 0.3183099, 0.3678794 );
        float n = 111.0*p.x + 113.0*p.y;
        return fract(n*fract(k*n));
    }

// Noise
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
        vec3  n = h*h*h*h*vec3( dot(a,hash2(i+0.0)), dot(b,hash2(i+o)), dot(c,hash2(i+1.0)));
        return dot( n, vec3(70.0) );
    }

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
        return f;
    }

// Functions
    vec3 rotate3D(vec3 point, vec3 rotation) {
        vec3 r = rotation;
        mat3 rz = mat3(cos(r.z), -sin(r.z), 0,
                    sin(r.z),  cos(r.z), 0,
                    0,         0,        1);
        mat3 ry = mat3( cos(r.y), 0, sin(r.y),
                        0       , 1, 0       ,
                    -sin(r.y), 0, cos(r.y));
        mat3 rx = mat3(1, 0       , 0        ,
                    0, cos(r.x), -sin(r.x),
                    0, sin(r.x),  cos(r.x));
        return rx * ry * rz * point;
    }

    float fmod(float a, float b) {
        if(a<0.0)
        {
            return b - mod(abs(a), b);
        }
        return mod(a, b);
    }
    
    float sminF( float a, float b, float k ) {
        float h =  max( k-abs(a-b), 0.0 )/k;
        float m = h*h*0.5;
        float s = m*k*(1.0/2.0);
        return (a<b) ? a-s : b-s;
    }

    float smaxF( float a, float b, float k ) {
        float h =  max( k-abs(a-b), 0.0 )/k;
        float m = h*h*0.5;
        float s = m*k*(1.0/2.0);
        return (a>b) ? a+s : b+s;
    }

    vec2 smin( float a, float b, float k ) {
        float h =  max( k-abs(a-b), 0.0 )/k;
        float m = h*h*0.5;
        float s = m*k*(1.0/2.0);
        return (a<b) ? vec2(a-s,m) : vec2(b-s,1.0-m);
    }

    vec3 sminV3( in vec4 a, in vec4 b, in float k )
    {
        float h =  max(k-abs(a.x-b.x),0.0);
        float m = 0.25*h*h/k;
        float n = 0.50*  h/k;
        return vec3(min(a.x,  b.x) - m, 
                    mix(a.yzw,b.yzw,(a.x<b.x)?n:1.0-n));
    }

    vec4 smoothUnion( vec4 d1, vec4 d2, float k ) {
        float h = clamp( 0.5 + 0.5*(d2.x-d1.x)/k, 0.0, 1.0 );
        vec4 r;
        r.x= mix( d2.x, d1.x, h ) - k*h*(1.0-h);
        r.yzw = mix( d2.yzw, d1.yzw, h );
        return r;
    }

// SDFs

    float sdS2(vec3 p, float s) {
        //p= vec3(0.,, p.z);
        float pV = uvReal.y;
        vec2 mouseV = clamp(mix(mouse, mouse1, pV), -1., 1.)*5.;
        p = vec3(p.x-mouseV.x, p.y+mouseV.y, p.z);
        vec2 tc = value.xy;
        float ra = value.z;
        float rb = value.w;
        vec2 sc = tc;

        // vec2 q = vec2(length(p.xy)-ra,p.z);
        // return length(q)-rb;
        float an = value.x;
        sc = vec2(sin(an),cos(an));
        //p.x += sin(p.y+time*tc.y);
        p.x = abs(p.x);
        // p.y += tc.y; // height
        float k = (sc.y*p.x > sc.x*p.y) ? dot(p.xy,sc) : length(p.xy);
        return sqrt( dot(p,p) + ra*ra - 2.0*ra*k ) - rb;
    }
    
    float sdS9( vec3 p, float s )
    {
        vec2 t = vec2(value.z,value.w);
        float circle = length(p.xy) * p.x;
        vec2 q = vec2(circle - t.x, p.z);
        float d = length(q) - t.y;
        return d;
    }

    float sdS3r2( vec3 p, float a ) //S
    {
        float h = 2.0;
        float r = 0.3 + value.w;
        float y = p.y - 1.;
        // p.x = p.x * sin(p.y+value.x)*value.y;
        p.x = sin(p.y * -value.x)*.7 + p.x;
        p.y -= clamp( p.y, 0.0, h );
        float d = length( p ) - r;
        return d;
    }

    float sdS6( vec3 p, float a ) //H
    {
        float h = 2.0;
        float r = 0.3 + value.w;
        vec2 p2 = p.xy;
        p.x = abs(p.x)-1.;
        p.y -= clamp( p.y, -h, h );
        p2.x -= clamp( p2.x, -1., h*.5 );
        float d1 = length( p ) - r;
        float d2 = length( vec3(p2.x, p2.y, p.z )) - r;
        return min(d1, d2);
    }

    float sdSa2(in vec3 p, float a ) //A2
    {
        float h = 2.0;
        float w = 2.5;
        float r = 0.3;
        p.x = mix( (p.y +  p.x * 2.0 - w) , 0. , (p.y -  p.x * 2.0 - w) );
        p.y -= clamp( p.y, 0.0, h );
        return length( p ) - r;
    }

    float sdSa(in vec3 p, float a) //A
    {
        float h = 2.0;
        float w = 2.5;
        float r = 0.3;

        float x = p.x*1.5 + p.y ;
        float y = p.y - p.x*1.5 ;
        y = smaxF(x, y, .5);
        x = p.x - clamp( p.x, -2.0, h );
        p.x -= clamp( p.x, -1.0, h*.5 );
        return min( length(p), length(vec3(x, y - 2., p.z))-.3 ) - r;
    }

    float sdS(in vec3 p, float a) //A
    {
        float h = 2.0;
        float w = 2.5;
        float r = 0.3;

        float x = p.x + p.y ;
        float y = p.y - p.x*1.5 ;

        // float y2 = p.y + p.x;
        // p.x -= p.y;
        // p.y = y2;

        p.xy = vec2(p.x+p.y, p.y-p.x-2.);

        p.y -= clamp( p.y, 0.0, h );
        return length(p) - r;
    }

    float sdS1(vec3 p, float s) {
        //p= vec3(0.,, p.z);
        float pV = uvReal.y;
        vec2 mouseV = clamp(mix(mouse, mouse1, pV), -1., 1.)*5.;
        p = vec3(p.x-mouseV.x, p.y+mouseV.y, p.z);
        vec2 tc = value.xy;
        float ra = value.z;
        float rb = value.w;
        vec2 sc = tc;

        // vec2 q = vec2(length(p.xy)-ra,p.z);
        // return length(q)-rb;
        float an = value.x;
        sc = vec2(sin(an),cos(an));
        //p.x += sin(p.y+time*tc.y);
        p.x = abs(p.x);
        // p.y += tc.y; // height
        float k = (sc.y*p.x > sc.x*p.y) ? dot(p.xy,sc) : length(p.xy);
        //float k = (sc.y*p.x > sc.x*p.y) ? dot(p.xy,sc) : length(p.xy);
        return sqrt( dot(p,p) + ra*ra - 2.0*ra*k ) - rb;
    
    }
    
    float hollowCube(in vec3 p, float a)
    {
        float h = 2.0;
        float w = 2.5;
        float r = 0.3;

        float x = p.x + p.y;
        float y = p.y - p.x;
        p.y -= clamp(0., 1., x) + clamp(0., 1., y);
        //p.y = p.y * tan(p.x - value.x );
        p.x -= clamp( p.x, -2.0, h );
        return length( p ) - r;
    }

    float sdArc( in vec2 p, in vec2 sc, in float ra, float rb )
    {
        p.x = abs(p.x);
        return ((sc.y*p.x>sc.x*p.y) ? length(p-sc*ra) : abs(length(p)-ra)) - rb;
    }

    float sdSphere(vec3 p, float s) { 
        return length(p) - s;
    }

    float sdPlane( vec3 p, vec3 n, float h ) {
        // n must be normalized
        return dot(p,n) + h;
    }
    
    float sdBox(vec3 p, vec3 radius)
    {
        vec3 dist = abs(p) - radius;
        return min(max(dist.x, max(dist.y, dist.z)), 0.0) + length(max(dist, 0.0));
    }
    
    float GlyphSDF2(vec2 p)
    {
        // p = fract(p*16.);
        // // p = p/16.;
        p.x -=.5;
        p = p*8.;
        // p *= 16.;
        // p.x += 5.;
        float char = charArr[0];
        // char = 66.;

        vec2 textPos = p;
        textPos.y += sin(time);
        float textScale = 5.;
        float distance3 = 1.;
        float charWidth = 1.;
        float charWidthTotal = charWidth * charLength /2. + textPos.x;
        // float charWidthTotal = charWidth * charLength /2. - 2.0 + textPos.x;
        vec2 charPos = p;
        float distTemp = 0.;
        float glyph;
        vec2 glyphUV;

        for(float i = 0.0; i < min(charLength, 25.); ++i )
        {
            charPos.x = charWidthTotal - i * charWidth;
        }
        charPos.y -= 5.;
        // p = abs(p.x) > .5 || abs(p.y) > .5 ? vec2(0.) : p += .5;

        glyphUV = charPos / 16. + fract(vec2(char, 15. - floor(char / 16.)) / 16.);
        
        float mask2 = step((charPos.x), 1. ) * step(abs(charPos.y), 1.);
        float mask = step((charPos.x-1.), 1. ) * mask2;

        glyphUV = vec2( mix(0., glyphUV.x, mask) , mix(0., glyphUV.y, mask) );
        // glyphUV *= 16.;
        glyph = 2. * (texture(textTex, glyphUV).w - 0.4980392157); //0.4980392157 = 127. / 255.
        // return mask2;
        return glyph;
        return glyphUV.x * glyphUV.y;
        return p.x * p.y;
    }

    vec2 glyphTest(vec2 p)
    {
        float char = charArr[0];
        p = abs(p.x) > .5 || abs(p.y) > .5 ? vec2(0.) : p += .5;
        vec2 glyphUV = p / 16. + fract(vec2(char, 15. - floor(char / 16.)) / 16.);
        float glyph = 2. * (texture(textTex, glyphUV).w - 127. / 255.);
        return glyphUV;
    }

    float textSDF2(vec3 p, float s)
    {
        p.xy /= s;
        float text = GlyphSDF2(p.xy);
        float cropBox = sdBox(p - vec3(0., 0.1, 0.), vec3(10., 1., .01));
        // return cropBox;
        return max(text, cropBox) + 0.05;
    }

// Backup
    float GlyphSDF(vec2 p, float char)
    {   
        p += .5;
        p = abs(p.x - .5) > .5 || abs(p.y - .5) > .5 ? vec2(0.) : p;
        return 2. * (texture(textTex, p / 16. + fract(vec2(char, 15. - floor(char / 16.)) / 16.)).w - 127. / 255.);
    }

    float textSDF(vec3 p, float s, float char)
    {
        p.xy /= s;
        float text = GlyphSDF(p.xy, char);
        float cropBox = sdBox(p - vec3(0., 0.1, 0.), vec3(100., 100., .01));
        return max(text, cropBox) + 0.05;
    }
    
    
// Raymarching
vec4 scene(vec3 position) {
    // Define Colors
    vec3 
        _White     = vec3(1.0, 1.0, 1.0),
        _Black     = vec3(0.0, 0.0, 0.0),
        _Red       = vec3(1.0, 0.4314, 0.3333),
        _Green     = vec3(0.0, 0.9882, 0.4941),
        _Blue      = vec3(0.0, 0.0, 1.0),
        _Cyan      = vec3(0.0, 1.0, 1.0),
        _Yellow    = vec3(1.0, 1.0, 0.0),
        _Megenta   = vec3(1.0, 0.0, 1.0);

    // Ground
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
    vec3 spsPos = vec3(0., -2.3, -4.) + position;
    //float distance3 = sdS(spsPos, 0.5);

    //float distance3 = GlyphSDF(uvReal, floor(value.w*100.));
    //float distance3 = GlyphSDF(uvReal, 65.);
    
    vec3 textPos = vec3(0., -1. , -3.) + position;
    textPos.y += sin(time);
    float textScale = 5.;
    float distance3 = 1.;
    float charWidth = 3.;
    float charWidthTotal = charWidth * charLength /2. - 2.0 + textPos.x;
    vec3 charPos = textPos;
    float distTemp = 0.;

    for(float i = 0.0; i < min(charLength, 25.); ++i )
    {
        charPos.x = charWidthTotal - i*charWidth;
        distTemp = textSDF(charPos, textScale, charArr[int(i)]);
        //if (i == 0.) distance3 = distTemp;
        distance3 = min(distance3, distTemp);
    }

    distance3 = textSDF2(charPos, textScale);

    vec4 //Merge all SDFs
        d = smoothUnion(vec4(distance, _Green), vec4(distance2, _White), 2.5);
        d = smoothUnion(vec4(d), vec4(distance3, vec3(color)), 0.5);

    //return vec4(distance3, vec3(color));
    return d;
}

vec4 raymarch(vec3 position, vec3 direction) {
    
    float total_distance = NEAR_CLIPPING_PLANE;
    for(int i = 0 ; i < NUMBER_OF_MARCH_STEPS ; ++i) {
        vec4 distance = scene(position + direction * total_distance);
        
        if(distance.x < EPSILON) { 
            return vec4(total_distance, distance.yzw); // If our ray is very close to a surface we assume we hit it and return it's material
        }
        // we can be sure that if we move it that far we will not accidentally end up inside an object. Due to imprecision we do increase the distance by slightly less.
        total_distance += distance.x * DISTANCE_BIAS;
        
        if(total_distance > FAR_CLIPPING_PLANE)
            break;
    }
    //discard;
    gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
    return vec4(FAR_CLIPPING_PLANE, vec3(0.));
}

vec3 normal1(vec3 ray_hit_position, float smoothness) {
    smoothness = 0.001;
	vec3 n;
	vec2 dn = vec2(smoothness, 0.0);
	n.x	= scene(ray_hit_position + dn.xyy).x - scene(ray_hit_position - dn.xyy).x;
	n.y	= scene(ray_hit_position + dn.yxy).x - scene(ray_hit_position - dn.yxy).x;
	n.z	= scene(ray_hit_position + dn.yyx).x - scene(ray_hit_position - dn.yyx).x;
	return normalize(n);
}

vec3 normal( in vec3 pos, float smoothness ) {
    //vec2 e = vec2(0.5773,-0.5773);
    vec2 e = vec2(-10.,200.);
    const float eps = 0.01;
    return normalize( e.xyy * scene( pos + e.xyy* eps ).x + 
					  e.yyx * scene( pos + e.yyx* eps ).x + 
					  e.yxy * scene( pos + e.yxy* eps ).x + 
					  e.xxx * scene( pos + e.xxx* eps ).x ); }
    
// Global
vec3 fog( in vec3 col, float t )
{
    // vec3 ext = exp2(-t*0.00025 * vec3(1., 1.5, 4.)); 
    // return col*ext + (1.0-ext) * vec3(0.5804, 0.549, 0.549); // 0.55
    vec3 ext = exp2(-t*0.25 * vec3(1., 1.5, 4.)); 
    return col*ext + (1.0-ext) * vec3(0.1333, 0.0, 0.2549); // 0.55
}

/*
// Main Function
void main()
{
    // #include <fog_vertex>

    vec3 direction = normalize(vec3(vertexUV, 2.5));
    // if you rotate the direction with a rotatin matrix you can turn the camera too!
    direction = rotate3D(direction, vec3(0., -key.y*.1, 0.));
    
    vec3 camera_origin = vec3(0.0, 2.0 + sin(time*2.), key.x-5.0); // you can move the camera here
    
    vec4 result = raymarch(camera_origin, direction);
    
    // arbitrary fog to hide artifacts near the far plane
    // float fog = pow(1.0 / (1.0 + result.x), 0.45);
    
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
    //diffuseLit = clamp(diffuseLit, 0.0, 1.0);
    diffuseLit = fog(diffuseLit, result.x* 0.1);
    float alpha = 1.;
    // alpha = result.x < FAR_CLIPPING_PLANE ? alpha : 0.0;
    gl_FragColor = vec4(sqrt(diffuseLit), alpha);
    //gl_FragColor = vec4(vec3(pV.x), 1.);
    //gl_FragColor = texture2D(textTex, uvReal);
}
*/


void main(){

    //vec4 tex = texture2D(textTex, GlyphSDF(vec2(0), 65.)*10.);
    // float t = value.x;
    // vec2 uv = uvReal * 1.;
    // float r = smoothstep(GlyphSDF( uvReal, floor(value.w*100.)), .001, .1);

    // float r = smoothstep(GlyphSDF( vertexUV, charArr[0]), .001, .1);
    float r = smoothstep(GlyphSDF2( uvReal ), .0, .1);

    //vec2 r = glyphTest(vec2(vertexUV));

    //gl_FragColor = tex;
    vec2 g = fract(vertexUV*.5);
    g =vertexUV;
    float grid = step(abs(g.x), 1.6) * step(abs(g.y), .5);
    gl_FragColor = vec4(vec2(r), 0., 1.);
}
