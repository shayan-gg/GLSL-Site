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
const renderer = new THREE.WebGLRenderer();
renderer.setSize(window.innerWidth, window.innerHeight);
document.body.appendChild(renderer.domElement);

const clock = new THREE.Clock();

// set initial camera position and rotation
//camera.position.set(500, 10, 500);
//camera.rotation.set(-Math.PI / 6, 0, 0);
camera.position.set(0, 0, 1);

let value;
let colorGUI = new THREE.Vector3();
const gui = new GUI();

  const guiObject = {
    value1: 3.14,
    value2: 3.14,
    value3: .7,
    value4: .2,
    color: { r: 1, g: 0, b: 0 },
  };

  gui.add( guiObject, 'value1', -3.14, 3.14 ).name('value 1');
  gui.add( guiObject, 'value2', -3.14, 3.14 ).name('value 2');
  gui.add( guiObject, 'value3', 0, 2 ).name('value 3');
  gui.add( guiObject, 'value4', 0, 2 ).name('value 4');
  gui.addColor( guiObject, 'color' );


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

const modelFile = './assets/b.glb';

let dummy = new THREE.Object3D();

const instances = new THREE.Vector2(20,20);

const loader = new GLTFLoader();

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
let charArr = [24];
let charLength = 1;

charArr[0] = 65;

const boxGeometry = new THREE.PlaneGeometry( 1.5, 1.5, 128, 128 ); 

const boxMaterial = new THREE.ShaderMaterial({
  uniforms: {
  	time:         { value: clock.getElapsedTime() },
  	resolution :  { value: new THREE.Vector2() },
    key :         { value: move },
    aspect :      { value: aspect },
    value :       { value: value },
    color :       { value: colorGUI },
    mouse :       { value: mousePos },
    mouse1 :      { value: mousePosDelayed },
    EPSv :        { value: 0.000005 },
    textTex :     { value: textTex },
    charArr :     { value: charArr },
    charLength :  { value: charLength },
  },
  vertexShader: boxVert,
  fragmentShader: boxFrag,
  side: THREE.DoubleSide,
});
const cube = new THREE.Mesh( boxGeometry, boxMaterial ); 
cube.scale.set(window.innerWidth/window.innerHeight, 1, 1);
scene.add( cube );

onmousemove = (e) => {
  mousePos = new THREE.Vector2(e.x/window.innerWidth*2 -1, e.y/window.innerHeight*2 -1);
  cube.material.uniforms.mouse.value = mousePos;
  //console.log(mousePos);
}

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
  // if (event.code === 'Backspace' && charLength === 0)
  // {
  //   cube.material.uniforms.charArr.value[0] = 32;
  // }
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

// create a ground plane
// const planeGeometry = new THREE.PlaneGeometry(1000, 1000, 3000, 3000);
// const planeMaterial = new THREE.ShaderMaterial({
//   uniforms: {
//   	time: { value: 1.0 },
//   	resolution: { value: new THREE.Vector2() },
//   },
//   vertexShader: groundVert,
//   fragmentShader: groundFrag,
// });
// const plane = new THREE.Mesh(planeGeometry, planeMaterial);
// plane.rotation.x = -Math.PI / 2;
// scene.add(plane);

// create a directional light
const light = new THREE.DirectionalLight(0xffffff, 5);
light.position.set(10, 20, 10);
scene.add(light);

// create a fog effect
const fogColor = 0x16ffff;
const fogNear = 10;
const fogFar = 500;
//scene.fog = new THREE.Fog(fogColor, fogNear, fogFar);
// scene.background = new THREE.Color(0x11ddFF);
renderer.setClearColor( 0xffffff, 0);
console.log(scene.background);

// create a clock for delta time
// const clock = new THREE.Clock();

// define movement speed and direction
const speed = 50; // units per second
const speedFast = 200;
let boost = false;
let moveForward = false;
let moveBackward = false;
let moveLeft = false;
let moveRight = false;

// add event listeners for keyboard input
document.addEventListener("keydown", (event) => {
  switch (event.code) {
    case "ShiftLeft":
      boost = true;
      break;
    case "KeyW":
    case "ArrowUp":
      moveForward = true;
      break;
    case "KeyS":
    case "ArrowDown":
      moveBackward = true;
      break;
    case "KeyA":
    case "ArrowLeft":
      moveLeft = true;
      break;
    case "KeyD":
    case "ArrowRight":
      moveRight = true;
      break;
  }
});

document.addEventListener("keyup", (event) => {
  // console.log(event.code);
  switch (event.code) {
    case "ShiftLeft":
      boost = false;
      break;
    case "KeyW":
    case "ArrowUp":
      moveForward = false;
      break;
    case "KeyS":
    case "ArrowDown":
      moveBackward = false;
      break;
    case "KeyA":
    case "ArrowLeft":
      moveLeft = false;
      break;
    case "KeyD":
    case "ArrowRight":
      moveRight = false;
      break;
  }
});


let tris = 0;
let trisPre = 0;

// define animation loop
function animate() {
  requestAnimationFrame(animate);

  const delta = clock.getDelta();

  // update camera controls
  //const hasControlsUpdated = cameraControls.update(delta);

  // update camera position based on movement input
  const direction = new THREE.Vector3();
  camera.getWorldDirection(direction);
  direction.y = 0; // ignore vertical component
  direction.normalize(); // make unit vector

  // console.log(boost);
  // if (moveForward) camera.position.addScaledVector(direction, (boost?speedFast:speed) * delta);
  // if (moveBackward) camera.position.addScaledVector(direction, -(boost?speedFast:speed) * delta);
  // if (moveLeft) camera.rotation.y += .03; // camera.position.addScaledVector(direction.cross(camera.up), -speed * delta);
  // if (moveRight) camera.rotation.y -= .03; // camera.position.addScaledVector(direction.cross(camera.up), speed * delta);

  // // keep camera above ground
  // if (camera.position.y < plane.position.y + 1) {
  //   camera.position.y = plane.position.y + 1;
  // }

  cube.material.uniforms.time.value = clock.getElapsedTime();
  value = new THREE.Vector4(guiObject.value1, guiObject.value2, guiObject.value3, guiObject.value4);
  colorGUI = guiObject.color;
  cube.material.uniforms.value.value = value;
  cube.material.uniforms.color.value = colorGUI;

  renderer.render(scene, camera);
  tris =  Math.floor(renderer.info.render.triangles/1000000);
  if (tris > trisPre){ console.log(tris + 'M'); trisPre = tris; }
  
  lastFrames[delay] = (mousePos);
  mousePosDelayed = new THREE.Vector2(lastFrames[0]);
  mousePosDelayed = new THREE.Vector2(mousePosDelayed.x.x, mousePosDelayed.x.y);
  cube.material.uniforms.mouse1.value = mousePosDelayed;
  lastFrames.shift();
  //console.log(mousePosDelayed);

  
  move.x += key.x*boostSpeed;
  move.y += key.y*boostSpeed;
  cube.material.uniforms.key.value = move;
}

// Handle window resizing events
function onWindowResize() {
  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();
  renderer.setSize(window.innerWidth, window.innerHeight);

  aspect = window.innerWidth/window.innerHeight;
  console.log('aspect ratio: ' + aspect);
  cube.scale.set(window.innerWidth/window.innerHeight, 1, 1);
  cube.material.uniforms.aspect.value = aspect;
  cube.material.uniforms.EPSv.value = 0.000005;
} window.addEventListener('resize', onWindowResize);

animate();