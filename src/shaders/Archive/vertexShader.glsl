// varying vec3 vertexPosition;
varying vec2 vertexUV;
uniform float offset;
#include <fog_pars_vertex>

float random(vec2 st){
    return fract(sin(dot(st, vec2(12.9898,78.233)))* 43758.5453123);
}

void main()
{
    #include <begin_vertex>
    #include <project_vertex>
    #include <fog_vertex>
    // vertexPosition = position;
    vertexUV = uv;
    float o = 0.0;
    float o2 = 0.0;
    for (int i = 0; i<4; i++) {
        for (int j = 0; j<4; j++) {
            o = (o + (modelMatrix[i][j])/100.0);
            o2 = (o + (modelMatrix[(j+i/2)][i])/100.0);
            // o = min(max(o + cameraPosition.x*.01, 0.0),900.0);
        }
    }

    //o = floor((sin(dot(o, 12.9898)* 43758.5453)/1.57)*10.0)*10.0;

    o = floor ( random(vec2(o2,o)) * 10.0) * 100.0;
    // o = modelMatrix[1][1] * 100.0;

    // vec3 vPos = vec3(position.x - o, position.y, position.z);
    vec3 vPos = vec3(position.x - o, position.y, position.z);
    if (vPos.x <= -50.0 || vPos.x >= 50.0) vPos = vec3(vPos.x, 0.0, 0.0);

    gl_Position = projectionMatrix * modelViewMatrix * vec4(vPos, 1.0);
}