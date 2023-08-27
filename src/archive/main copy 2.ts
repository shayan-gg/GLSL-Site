// code block
import * as THREE from "three";
import CameraControls from "camera-controls";
import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader.js';
import Stats from 'three/examples/jsm/libs/stats.module.js';
import GUI from 'three/examples/jsm/libs/lil-gui.module.min.js';
// import { MeshoptDecoder } from 'three/examples/jsm/libs/meshopt_decoder.module.js';

import vert from './shaders/vertexShader.glsl';
import frag from './shaders/fragmentShader.glsl';
import groundVert from './shaders/groundVert.glsl';
import groundFrag from './shaders/groundFrag.glsl';

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
const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 100000);
const renderer = new THREE.WebGLRenderer();
renderer.setSize(window.innerWidth, window.innerHeight);
document.body.appendChild(renderer.domElement);

// set initial camera position and rotation
camera.position.set(500, 10, 500);
//camera.rotation.set(-Math.PI / 6, 0, 0);

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

// const randomizeMatrix = function () {

//   const position = new THREE.Vector3();
//   const rotation = new THREE.Euler();
//   const quaternion = new THREE.Quaternion();
//   const scale = new THREE.Vector3();

//   return function ( matrix ) {

//     position.x = Math.random() * 40 - 20;
//     position.y = Math.random() * 40 - 20;
//     position.z = Math.random() * 40 - 20;

//     rotation.x = Math.random() * 2 * Math.PI;
//     rotation.y = Math.random() * 2 * Math.PI;
//     rotation.z = Math.random() * 2 * Math.PI;

//     quaternion.setFromEuler( rotation );

//     scale.x = scale.y = scale.z = Math.random() * 1;

//     matrix.compose( position, quaternion, scale );

//   };

// }();

// function makeInstanced( geometry ) {

//   const matrix = new THREE.Matrix4();
//   const mesh = new THREE.InstancedMesh( geometry, material, api.count );

//   for ( let i = 0; i < api.count; i ++ ) {

//     randomizeMatrix( matrix );
//     mesh.setMatrixAt( i, matrix );

//   }

//   scene.add( mesh );

//   //

//   const geometryByteLength = getGeometryByteLength( geometry );

//   guiStatsEl.innerHTML = [

//     '<i>GPU draw calls</i>: 1',
//     '<i>GPU memory</i>: ' + formatBytes( api.count * 16 + geometryByteLength, 2 )

//   ].join( '<br/>' );

// }

const customMat = new THREE.ShaderMaterial({
  uniforms: {
  	time: { value: 1.0 },
  	resolution: { value: new THREE.Vector2() },
    offset: { value: Math.floor(Math.random() * 10) * 100 },
  },
  vertexShader: vert,
  fragmentShader: frag,
  fog : true
});

const modelFile = './assets/b.glb';

let dummy = new THREE.Object3D();

const instances = new THREE.Vector2(20,20);

const loader = new GLTFLoader();
// loader.load(
//   modelFile,
//   (gltf) => {
//     const model = gltf.scene;
//     // model.children[0].material = customMat;
//     //scene.add(model);
//     // console.log(model);

//     for(let i = 0; i < instances.x; i++){
//       for(let j = 0; j < instances.y; j++){
//         let instancedMesh = new THREE.InstancedMesh(model.children[0].geometry, customMat, 1);
//         instancedMesh.position.x = (100 * i);
//         instancedMesh.position.z = (100 * j);
//         instancedMesh.setMatrixAt(0, dummy.matrix);
//         scene.add(instancedMesh);
//       }
//     }
// });

//for (let i = 0; i < 2; i++) {
  // for (let j = 0; j < instances.y; j++) {
  //   loader.load( modelFile, (gltf) => {
  //     const model = gltf.scene;
  //     whiteMat(model.children[0].material = new THREE.MeshPhongMaterial);
  //     // model.position.z = (100 * j); 
  //     scene.add(model);
  //   });
  // }
//}




// create a ground plane
const planeGeometry = new THREE.PlaneGeometry(10000, 10000);
const planeMaterial = new THREE.ShaderMaterial({
  uniforms: {
  	time: { value: 1.0 },
  	resolution: { value: new THREE.Vector2() },
  },
  vertexShader: groundVert,
  fragmentShader: groundFrag,
});

const plane = new THREE.Mesh(planeGeometry, planeMaterial);
plane.rotation.x = -Math.PI / 2;
scene.add(plane);

// create a directional light
const light = new THREE.DirectionalLight(0xffffff, 5);
light.position.set(10, 20, 10);
scene.add(light);

// create a fog effect
const fogColor = 0x16ffff;
const fogNear = 10;
const fogFar = 500;
scene.fog = new THREE.Fog(fogColor, fogNear, fogFar);
scene.background = new THREE.Color(fogColor)

// create a clock for delta time
const clock = new THREE.Clock();

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
  if (moveForward) camera.position.addScaledVector(direction, (boost?speedFast:speed) * delta);
  if (moveBackward) camera.position.addScaledVector(direction, -(boost?speedFast:speed) * delta);
  if (moveLeft) camera.rotation.y += .03; // camera.position.addScaledVector(direction.cross(camera.up), -speed * delta);
  if (moveRight) camera.rotation.y -= .03; // camera.position.addScaledVector(direction.cross(camera.up), speed * delta);

  // keep camera above ground
  if (camera.position.y < plane.position.y + 1) {
    camera.position.y = plane.position.y + 1;
  }

  renderer.render(scene, camera);
  tris =  Math.floor(renderer.info.render.triangles/1000000);
  if (tris > trisPre){ console.log(tris + 'M'); trisPre = tris; }
}

// Handle window resizing events
function onWindowResize() {
  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();
  renderer.setSize(window.innerWidth, window.innerHeight);
} window.addEventListener('resize', onWindowResize);

animate();