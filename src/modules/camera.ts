import { Color, Scene, Fog } from 'three';

function camera ()
{   
    const scene = new Scene();
    const fogColor = 0x16ffff;
    const fogNear = 10;
    const fogFar = 50;
    scene.fog = new Fog(fogColor, fogNear, fogFar);
    scene.background = new Color(fogColor);
    return scene.fog, scene.background;
}

export { camera };