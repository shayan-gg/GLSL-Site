// varying vec3 position;
varying vec2 vertexUV;
#include <fog_pars_vertex>

void main()
{
    #include <fog_vertex>
    vec3 col = vec3(vertexUV, 1.0);
    gl_FragColor = vec4(col, 1.0);
}