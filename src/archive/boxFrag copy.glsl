uniform float time;

varying vec3 vertexPosition;
varying vec2 vertexUV;
// #include <fog_pars_vertex>

#define NEAR_CLIPPING_PLANE 0.1
#define FAR_CLIPPING_PLANE 10000.0
#define NUMBER_OF_MARCH_STEPS 40
#define EPSILON 0.01
#define DISTANCE_BIAS 0.7

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

float sdSphere(vec3 p, float s)
{
	return length(p) - s;
}

float fmod(float a, float b)
{
    if(a<0.0)
    {
        return b - mod(abs(a), b);
    }
    return mod(a, b);
}

vec2 scene(vec3 position)
{
    /*
	This function generates a distance to the given position
	The distance is the closest point in the world to that position
	*/
    // to move the sphere one unit forward, we must subtract that translation from the world position
    vec3 translate = vec3(0.0, -0.5, 1.0);
    float distance = sdSphere(position - translate, 0.5);
	float materialID = 1.0;
    
    translate = vec3(0.0, 0.5, 1.0);
    // A power of raymarching is tiling, we can modify the position in any way we want
    // leaving the shape as is, creating various results
    // So let's tile in X with a sine wave offset in Y!
    vec3 sphere_pos = position - translate;
    // Because our sphere starts at 0 just tiling it would cut it in half, with
    // the other half on the other side of the tile. SO instead we offset it by 0.5
    // then tile it so it stays in tact and then do -0.5 to restore the original position.
    // When tiling by any tile size, offset your position by half the tile size like this!
    sphere_pos.x = fract(sphere_pos.x + 0.5) - 0.5; // fract() is mod(v, 1.0) or in mathemathical terms x % 1.0
    sphere_pos.z = fmod(sphere_pos.z + 1.0, 2.0) - 1.0; // example without fract
    // now let's animate the height!
    sphere_pos.y += sin(position.x + time) * 0.35; //add time to animate, multiply by samll number to reduce amplitude
    sphere_pos.y += cos(position.z + time);
    float distance2 = sdSphere(sphere_pos, 0.25);
	float materialID2 = 2.0; // the second sphere should have another colour
    
    // to combine two objects we use the minimum distance
    if(distance2 < distance)
    {
		distance = distance2;
        materialID = materialID2;
    }
    
    // we return a vec2 packing the distance and material of the closes object together
    return vec2(distance, materialID);
}

vec2 raymarch(vec3 position, vec3 direction)
{
    /*
	This function iteratively analyses the scene to approximate the closest ray-hit
	*/
    // We track how far we have moved so we can reconstruct the end-point later
    float total_distance = NEAR_CLIPPING_PLANE;
    for(int i = 0 ; i < NUMBER_OF_MARCH_STEPS ; ++i)
    {
        vec2 result = scene(position + direction * total_distance);
        // If our ray is very close to a surface we assume we hit it
        // and return it's material
        if(result.x < EPSILON)
        {
            return vec2(total_distance, result.y);
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
    return vec2(FAR_CLIPPING_PLANE, 0.0);
}

vec3 normal(vec3 ray_hit_position, float smoothness)
{	
	vec3 n;
	vec2 dn = vec2(smoothness, 0.0);
	n.x	= scene(ray_hit_position + dn.xyy).x - scene(ray_hit_position - dn.xyy).x;
	n.y	= scene(ray_hit_position + dn.yxy).x - scene(ray_hit_position - dn.yxy).x;
	n.z	= scene(ray_hit_position + dn.yyx).x - scene(ray_hit_position - dn.yyx).x;
	return normalize(n);
}

void main()
{
    // #include <fog_vertex>

    vec3 direction = normalize(vec3(vertexUV, 2.5));
    // if you rotate the direction with a rotatin matrix you can turn the camera too!
    
    vec3 camera_origin = vec3(0.0, 0.0, -2.5); // you can move the camera here
    
    vec2 result = raymarch(camera_origin, direction); // this raymarches the scene
    
    // arbitrary fog to hide artifacts near the far plane
    // 1.0 / distance results in a nice fog that starts white
    // but if distance is 0 
    float fog = pow(1.0 / (1.0 + result.x), 0.45);
    
    // now let's pick a color
    vec3 materialColor = vec3(0.0, 0.0, 0.0);
    if(result.y == 1.0)
    {
        materialColor = vec3(1.0, 0.25, 0.1);
    }
    if(result.y == 2.0)
    {
       	materialColor = vec3(0.7, 0.7, 0.7);
    }
    
    // We can reconstruct the intersection point using the distance and original ray
    vec3 intersection = camera_origin + direction * result.x;
    
    // The normals can be retrieved in a fast way
    // by taking samples close to the end-result sample
    // their resulting distances to the world are used to see how the surface curves in 3D
    // This math I always steal from somewhere ;)
    vec3 nrml = normal(intersection, 0.01);
    
    // Lambert lighting is the dot product of a directional light and the normal
    vec3 light_dir = normalize(vec3(0.0, 1.0, 0.0));
   	float diffuse = dot(light_dir, nrml);
    // Wrap the lighting around
    // https://developer.valvesoftware.com/wiki/Half_Lambert
    // diffuse = diffuse * 0.5 + 0.5;
    // For real diffuse, use this instead (to avoid negative light)
    diffuse = max(0.0, diffuse);
    
    // Combine ambient light and diffuse lit directional light
    vec3 light_color = vec3(1.4, 1.2, 0.7);
    vec3 ambient_color = vec3(0.2, 0.45, 0.6);
    vec3 diffuseLit = materialColor * (diffuse * light_color + ambient_color);

    gl_FragColor = vec4(vec3(diffuseLit), diffuse);
}