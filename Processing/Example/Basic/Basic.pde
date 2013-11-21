import camcam.*;
import simpleTween.*; // must import this too

PVSTween pvst; // sample simpleTween

CamCam cam;
float bounds = 200f;

void setup() {
  size(500, 500, P3D);
  cam = new CamCam(this);
  cam.useLeftMouseForControl();
  cam.toTopView();

  pvst = new PVSTween(100, 0, new PVector(), new PVector());
} // end setup

void draw() {
  background(0);
  cam.useCamera();
  drawGrid(200, 20);
  drawOrigin();

  // draw the current value of the pvst
  pushMatrix();
  noStroke();
  fill(255, 0, 0);
  translate(pvst.value().x, pvst.value().y, pvst.value().z);
  sphere(15);
  popMatrix();

  // draw the begin
  pushMatrix();
  translate(pvst.getBegin().x, pvst.getBegin().y, pvst.getBegin().z);
  fill(255, 0, 0, 50);
  sphere(10);
  popMatrix();

  // draw the end
  pushMatrix();
  translate(pvst.getEnd().x, pvst.getEnd().y, pvst.getEnd().z);
  fill(0, 255, 0, 50);
  sphere(10);
  popMatrix();

  // check if the tween is playing
  cam.pauseCamera();
  if (pvst.isPlaying()) fill(0, 255, 0);
  else fill(255, 0, 0);
  textAlign(LEFT, TOP);
  text("pvst is playing: " + pvst.isPlaying(), 20, 20);
  
  // instructions
  fill(127);
  text("x - assign new random value to pvst with duration", 20, 40);
  text("c - assign new random value to pvst with 0 duration", 20, 60);
  text("t - move camera view with duration", 20, 80);
  text("y - move camera view with 0 duration", 20, 100);
  text("SPACE - pause/resume pvst", 20, 120);
} // end draw




void keyReleased() {
  // camera control example
  if (key == 't') {
    println("cam stuff:");
    // make the camera focus on the end spot of pvst
    PVector newCamTarget = pvst.getEnd().get();
    float randomAngle = random(TWO_PI);
    PVector newCamPosition = new PVector(newCamTarget.x + bounds * cos(randomAngle), newCamTarget.y + bounds * sin(randomAngle), newCamTarget.z + random(-bounds/2, bounds/2));
    // .setView(PVector newPosition, PVector newTarget, float duration); // to set a custom duration
    float duration = 100f; 
    cam.setView(newCamPosition, newCamTarget, duration);
    println("new camera target: " + cam.getCameraTarget());
    println("new camera position: " + cam.getCameraPosition());
  }
  if (key == 'y') {
    // .setView(PVector newPosition, PVector newTarget) // move camera view with a duration of 0
    cam.setView(new PVector(400, 400, 400), new PVector(100, 100, 100));
  }

  if (key == 'x') {
    println("_pvst:");
    // .playLive(PVector newTarget) // delay duration will be the what it was last set to 
    pvst.playLive(new PVector(random(-bounds, bounds), random(-bounds, bounds), random(-bounds, bounds)));

    // or: .playLive(PVector newTarget, float duration, float delay) // uses this duration and delay
    //float duration = 200f;
    //float delay = 40f;
    //pvst.playLive(new PVector(random(-bounds, bounds), random(-bounds, bounds), random(-bounds, bounds)), duration, delay);

    println("current state of pos: " + pvst.value()); // returns PVector of current value of the PVSTween
    println("end of pos: " + pvst.getEnd()); // returns PVector of where it's going
    println("start of pos: " + pvst.getBegin()); // returns PVector of where the most recent PVSTween started
  }
  if (key == 'c') {
    // .setCurrent(PVector newTarget)
    pvst.setCurrent(new PVector(random(-bounds, bounds), random(-bounds, bounds), random(-bounds, bounds)));
  }

  if (key == ' ') {
    if (pvst.isPlaying()) {
      if (pvst.isPaused()) pvst.resume();
      else pvst.pause();
    }
  }
} // end keyReleased






void drawGrid(float gridExtents, float gridSize) {
  noFill();
  stroke(255, 55);
  strokeWeight(1);
  for (float i = -gridExtents; i<= gridExtents; i+= gridSize) {
    line(-gridExtents, i, gridExtents, i);
    line(i, -gridExtents, i, gridExtents);
  }
} // end drawGrid

void drawOrigin() {
  pushStyle();
  colorMode(HSB, 360);
  strokeWeight(1);
  stroke(0, 360, 360);
  line(-30, 0, 0, 100, 0, 0);
  stroke(107, 360, 360);
  line(0, -30, 0, 0, 100, 0);
  stroke(236, 360, 360);
  line(0, 0, -30, 0, 0, 100);
  popStyle();
} // end drawOrigin

