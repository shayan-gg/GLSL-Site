// Importing the necessary modules from three js
import { Scene, PerspectiveCamera, WebGLRenderer, BoxGeometry, MeshBasicMaterial, Mesh } from 'three';

// Creating a scene object
const scene = new Scene();

// Creating a camera with a field of view of 75 degrees, an aspect ratio of 2, and a near and far clipping plane of 0.1 and 5 respectively
const camera = new PerspectiveCamera(75, 2, 0.1, 5);

// Creating a renderer with antialiasing enabled
const renderer = new WebGLRenderer({ antialias: true });

// Setting the renderer size to match the window size
renderer.setSize(window.innerWidth, window.innerHeight);

// Adding the renderer canvas element to the document body
document.body.appendChild(renderer.domElement);

// Creating a box geometry with dimensions of 1 x 1 x 1
const geometry = new BoxGeometry(1, 1, 1);

// Creating a material with a red color
const material = new MeshBasicMaterial({ color: 0xff0000 });

// Creating a mesh by combining the geometry and the material
const cube = new Mesh(geometry, material);

// Adding the cube to the scene
scene.add(cube);

// Moving the camera back so that the cube is visible
camera.position.z = 2;

// Adding an event listener for keydown events
window.addEventListener('keydown', (event) => {
  // Checking which key was pressed
  switch (event.key) {
    // If W was pressed, move the camera forward by 0.1 units
    case 'w':
      camera.translateZ(-0.1);
      break;
    // If S was pressed, move the camera backward by 0.1 units
    case 's':
      camera.translateZ(0.1);
      break;
    // If A was pressed, rotate the camera left by 0.01 radians
    case 'a':
      camera.rotation.y += 0.01;
      break;
    // If D was pressed, rotate the camera right by 0.01 radians
    case 'd':
      camera.rotation.y -= 0.01;
      break;
    // If Q was pressed, rotate the camera up by 0.01 radians
    case 'q':
      camera.rotation.x -= 0.01;
      break;
    // If E was pressed, rotate the camera down by 0.01 radians
    case 'e':
      camera.rotation.x += 0.01;
      break;
    // Default case: do nothing
    default:
      break;
  }
});

// Creating a render loop function that animates the cube and renders the scene
function animate() {
  // Requesting the next animation frame
  requestAnimationFrame(animate);

  // Rotating the cube on its x and y axes
  cube.rotation.x += 0.01;
  cube.rotation.y += 0.01;

  // Rendering the scene with the camera
  renderer.render(scene, camera);
}

// Calling the animate function to start the render loop
animate();