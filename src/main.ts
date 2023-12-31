// code block
import * as THREE from "three";
import CameraControls from "camera-controls";
import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader.js';
import Stats from 'three/examples/jsm/libs/stats.module.js';
import GUI from 'three/examples/jsm/libs/lil-gui.module.min.js';
// import { MeshoptDecoder } from 'three/examples/jsm/libs/meshopt_decoder.module.js';

// import vert from './shaders/vertexShader.glsl';
// import frag from './shaders/fragmentShader.glsl';
// import groundVert from './shaders/groundVert.glsl';
// import groundFrag from './shaders/groundFrag.glsl';
import boxVert from './shaders/boxVert.glsl';
import boxFrag from './shaders/texFrag.glsl';
import { clamp } from "three/src/math/MathUtils";

const textTex = new THREE.TextureLoader().load('./assets/text.png');

const stats = () => {
  const stats1 = new Stats();
  stats1.showPanel(0);
  const stats2 = new Stats();
  stats2.showPanel(1);
  stats2.dom.style.cssText = 'position:absolute;top:0px;left:80px;';
  const stats3 = new Stats();
  stats3.showPanel(2);
  stats3.dom.style.cssText = 'position:absolute;top:0px;left:160px;';
  document.body.appendChild(stats1.dom);
  document.body.appendChild(stats2.dom);
  document.body.appendChild(stats3.dom);
  
  function statsUpdate() {
    requestAnimationFrame(statsUpdate);
    stats1.update();
    stats2.update();
    stats3.update();
  }statsUpdate();
}; stats();

// install camera controls
CameraControls.install({ THREE: THREE });

// create scene, camera and renderer
const scene = new THREE.Scene();
const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
const renderer = new THREE.WebGLRenderer({ antialias: true });
renderer.setSize(window.innerWidth, window.innerHeight);
document.body.appendChild(renderer.domElement);

const clock = new THREE.Clock();

// set initial camera position and rotation
//camera.position.set(500, 10, 500);
//camera.rotation.set(-Math.PI / 6, 0, 0);
camera.position.set(0, 0, .5);

let value;
let colorGUI = new THREE.Vector3();
const gui = new GUI();
const guiCam = gui.addFolder('Camera Control');

  const guiObject = {
    value1: 3.14,
    value2: 3.14,
    value3: 4,
    value4: 2,
    color: { r: 1, g: 0, b: 0 },
  };

  guiCam.add( guiObject, 'value1', -3.14, 3.14 ).name('value 1');
  guiCam.add( guiObject, 'value2', -3.14, 3.14 ).name('value 2');
  guiCam.add( guiObject, 'value3', 0, 10 ).name('FOV');  
  guiCam.add( guiObject, 'value4', 0, 10 ).name('Sensor Size');
  guiCam.addColor( guiObject, 'color' );


function whiteMat(mat) {
  mat.color.set('#202020')
  // mat.map = e
  mat.roughness = 0.7
  mat.metalness = 0
  mat.emissive.set('#FF0000')
  mat.emissiveIntensity = 0
  mat.opacity = 1
  // mat.refractionRatio = 0.98
  mat.transparent = false
  mat.dithering = false
  mat.side = 2
  //mat.envMap = e
  // mat.envMapIntensity = 10
  mat.flatShading = true
  // mat.morphTargets = false
  // mat.morphNormals = false
}

function norMat(mat) {
  // mat.color.set('#202020')
  // mat.map = e
  // mat.roughness = 0.7
  // mat.metalness = 0
  // mat.emissive.set('#FF0000')
  mat.emissiveIntensity = 0
  mat.opacity = 1
  // mat.refractionRatio = 0.98
  mat.transparent = false
  mat.dithering = false
  mat.side = 2
  //mat.envMap = e
  // mat.envMapIntensity = 10
  mat.flatShading = true
  // mat.morphTargets = false
  // mat.morphNormals = false
}

// const customMat = new THREE.ShaderMaterial({
//   uniforms: {
//   	time: { value: 1.0 },
//   	resolution: { value: new THREE.Vector2() },
//     offset: { value: Math.floor(Math.random() * 10) * 100 },
//   },
//   vertexShader: vert,
//   fragmentShader: frag,
//   fog : true
// });

const monitorGLB = './assets/monitor-y.glb';
const loader = new GLTFLoader();

let dummy = new THREE.Object3D();
const instances = new THREE.Vector2(20,20);

//
let key = new THREE.Vector2(0, 0);
let move = new THREE.Vector2(0, 0);
let mousePos = new THREE.Vector2(0, 0);
let mousePosDelayed = new THREE.Vector2(0, 0);
let moveSpeed = 0.1;
let boostSpeed = 1;
let aspect = window.innerWidth/window.innerHeight;
let lastFrames = [];
let delay = 7; //frames
// let charArr = [];
let charLength = 0;

// charArr[0] = [65];
let charArr = [72,105,44,32,73,32,97,109,32,83,104,97,121,97,110,32,65,110,115,97,114,105];
// charLength = 22;

const boxGeometry = new THREE.PlaneGeometry( 1.5, 1.5, 128, 128 ); 

const myShader = new THREE.ShaderMaterial({
  uniforms: {
  	time:         { value: clock.getElapsedTime() },
    key :         { value: move },
    aspect :      { value: 2 },
    value :       { value: value },
    color :       { value: colorGUI },
    mouse :       { value: mousePos },
    mouse1 :      { value: mousePosDelayed },
    textTex :     { value: textTex },
    charArr :     { value: charArr },
    charLength :  { value: charLength },
  },
  vertexShader: boxVert,
  fragmentShader: boxFrag,
  side: THREE.DoubleSide,
});
const cube = new THREE.Mesh( boxGeometry, myShader ); 
cube.scale.set(window.innerWidth/window.innerHeight, 1, 1);
// scene.add( cube );

let monitor;
loader.load( monitorGLB, function( gltf ) {
  scene.add(gltf.scene);
  // monitor = gltf.scene;
  gltf.scene.position.set(0, 0, 0);
  gltf.scene.children[0].children[2].material = myShader;
  console.log(gltf.scene.children[0].children[2].material)
});

// console.log(monitor);
// scene.add(monitor);

onwheel = (e) =>{
  console.log(camera.position.z);
  camera.position.z = clamp((camera.position.z + e.deltaY * 0.001), 0.5, 3 );
}


onmousemove = (e) => {
  mousePos = new THREE.Vector2(e.x/window.innerWidth*2 -1, e.y/window.innerHeight*2 -1);
  cube.material.uniforms.mouse.value = mousePos;
  //console.log(mousePos);
}


let textLine1 = [72,105,44];
let textLine2 = [73,32,97,109,32,83,104,97,121,97,110,32,65,110,115,97,114,105];
let textLine3 = [87,101,108,99,111,109,101,32,116,111,32,109,121,32,83,105,116,101];
let textLine4 = [83,99,114,111,108,108,32,116,111,32,99,111,110,116,105,110,117,101,];
let textLine = [textLine1, textLine2, textLine3, textLine4];
let lineCounter = 0;
let lineDelay = 100;

// setInterval(typeText, lineDelay);

function typeText() {
  if(charLength <= textLine[lineCounter].length) {
    cube.material.uniforms.charArr.value = textLine[lineCounter];
    cube.material.uniforms.charLength.value = Math.min(++charLength, textLine[lineCounter].length);
    setTimeout(typeText, 100);
  } else {
    charLength = 0;
    // cube.material.uniforms.charArr.value = textLine2;
    console.log(lineCounter);
    if (lineCounter < 3) {
      lineCounter++;
      console.log('t');
    }
    else {
      lineCounter = 0;
      console.log('f');
    }
    setTimeout(typeText, 1000);
  }
}; typeText();

document.addEventListener("keydown", (event) => {
  switch (event.code) {
    case "ShiftLeft":
      boostSpeed = 10;
      break;
    case "KeyW":
    case "ArrowUp":
      key.x = moveSpeed;
      break;
    case "KeyS":
    case "ArrowDown":
      key.x = -moveSpeed;
      break;
    case "KeyA":
    case "ArrowLeft":
      key.y = -moveSpeed;
      break;
    case "KeyD":
    case "ArrowRight":
      key.y = moveSpeed;
      break;
  }
});

document.addEventListener("keyup", (event) => {
  switch (event.code) {
    case "ShiftLeft":
      boostSpeed = 1;
      break;
    case "KeyW":
    case "ArrowUp":
      key.x = 0;
      break;
    case "KeyS":
    case "ArrowDown":
      key.x = 0;
      break;
    case "KeyA":
    case "ArrowLeft":
      key.y = 0;
      break;
    case "KeyD":
    case "ArrowRight":
      key.y = 0;
      break;
  }
});

document.addEventListener("keypress", (event) => {
  // console.log(event);
  if( charArr.length < 25 )
  charArr.push(event.which);
  charLength = charArr.length;
  console.log(cube.material.uniforms.charArr.value);
  cube.material.uniforms.charLength.value = charLength;
});

document.addEventListener("keydown", (event) => {
  console.log(cube.material.uniforms.charLength.value);
  if (event.code === 'Backspace' && charArr.length !== 0)
  {
    charArr.pop();
    charLength = charArr.length;
    console.log(charArr);
    cube.material.uniforms.charArr.value = charArr;
    cube.material.uniforms.charLength.value = charLength;
  }
});

// create a directional light
const light = new THREE.DirectionalLight(0xffffff, 5);
light.position.set(10, 20, 10);
scene.add(light);

// // create a fog effect
// const fogColor = 0x16ffff;
// const fogNear = 10;
// const fogFar = 500;
//scene.fog = new THREE.Fog(fogColor, fogNear, fogFar);
scene.background = new THREE.Color(0x11ddFF);
renderer.setClearColor( 0xffffff, 0);
console.log(scene.background);

// define movement speed and direction
// const speed = 50; // units per second
// const speedFast = 200;
// let boost = false;
// let moveForward = false;
// let moveBackward = false;
// let moveLeft = false;
// let moveRight = false;

// add event listeners for keyboard input
// document.addEventListener("keydown", (event) => {
//   switch (event.code) {
//     case "ShiftLeft":
//       boost = true;
//       break;
//     case "KeyW":
//     case "ArrowUp":
//       moveForward = true;
//       break;
//     case "KeyS":
//     case "ArrowDown":
//       moveBackward = true;
//       break;
//     case "KeyA":
//     case "ArrowLeft":
//       moveLeft = true;
//       break;
//     case "KeyD":
//     case "ArrowRight":
//       moveRight = true;
//       break;
//   }
// });

// document.addEventListener("keyup", (event) => {
//   // console.log(event.code);
//   switch (event.code) {
//     case "ShiftLeft":
//       boost = false;
//       break;
//     case "KeyW":
//     case "ArrowUp":
//       moveForward = false;
//       break;
//     case "KeyS":
//     case "ArrowDown":
//       moveBackward = false;
//       break;
//     case "KeyA":
//     case "ArrowLeft":
//       moveLeft = false;
//       break;
//     case "KeyD":
//     case "ArrowRight":
//       moveRight = false;
//       break;
//   }
// });

// define animation loop
function animate() {
  requestAnimationFrame(animate);

  // const delta = clock.getDelta();

  // update camera controls
  //const hasControlsUpdated = cameraControls.update(delta);

  // update camera position based on movement input
  // const direction = new THREE.Vector3();
  // camera.getWorldDirection(direction);
  // direction.y = 0; // ignore vertical component
  // direction.normalize(); // make unit vector

  cube.material.uniforms.time.value = clock.getElapsedTime();
  value = new THREE.Vector4(guiObject.value1, guiObject.value2, guiObject.value3, guiObject.value4);
  colorGUI = guiObject.color;
  cube.material.uniforms.value.value = value;
  cube.material.uniforms.color.value = colorGUI;
  
  lastFrames[delay] = (mousePos);
  mousePosDelayed = new THREE.Vector2(lastFrames[0]);
  mousePosDelayed = new THREE.Vector2(mousePosDelayed.x.x, mousePosDelayed.x.y);
  cube.material.uniforms.mouse1.value = mousePosDelayed;
  lastFrames.shift();

  move.x += key.x*boostSpeed;
  move.y += key.y*boostSpeed;
  cube.material.uniforms.key.value = move;

  renderer.render(scene, camera);

}

// Handle window resizing events
function onWindowResize() {
  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();
  renderer.setSize(window.innerWidth, window.innerHeight);

  aspect = window.innerWidth/window.innerHeight;
  console.log('aspect ratio: ' + aspect);
  cube.scale.set(window.innerWidth/window.innerHeight, 1, 1);
  // cube.material.uniforms.aspect.value = aspect;
} window.addEventListener('resize', onWindowResize);

animate();